// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {HellboxPublication} from "./HellboxPublication.sol";
import {HellboxBirthPolicy} from "./HellboxBirthPolicy.sol";
import {IHellboxRandomnessVerifier} from "./interfaces/IHellboxRandomnessVerifier.sol";
import {HellboxDrandEvmnetVerifier} from "./randomness/HellboxDrandEvmnetVerifier.sol";
import {EIP712} from "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

/// @dev Narrow immutable provenance surface exposed by an approved metadata
///      renderer generation. The factory reads it only to prove that a freshly
///      deployed renderer matches the release's frozen renderer commitment.
interface IHellboxRendererProvenance {
    function rendererId() external view returns (bytes32);
    function rendererVersion() external view returns (uint256);
    function interfaceVersion() external view returns (uint256);
    function artDataStore() external view returns (address);
    function artDataStoreCodeHash() external view returns (bytes32);
    function canvasWidth() external view returns (uint256);
    function canvasHeight() external view returns (uint256);
}

/// @dev Narrow immutable provenance surface exposed by HellboxPrimarySale.
///      The factory deploys exact hash-approved creation code, then verifies
///      these bindings before recording the one permanent sale for a publication.
interface IHellboxPrimarySaleProvenance {
    function PRIMARY_SALE_ID() external view returns (bytes32);

    function PRIMARY_SALE_VERSION() external view returns (uint256);

    function publication() external view returns (address);

    function publicationFactory() external view returns (address);

    function releaseChainId() external view returns (uint256);

    function publicationReleaseConfigDigest() external view returns (bytes32);

    function publicationCommitmentsDigest() external view returns (bytes32);

    function saleConfigDigest() external view returns (bytes32);
}

/// @title HellboxPublicationFactory
/// @notice Gate 4 V1 factory for manufacturing official full-deployment
///         publications and their exact immutable primary-sale checkouts.
/// @dev Authenticity is rooted outside this contract by Hellbox recognizing this
///      factory address as an approved factory for the target chain/version.
///
///      V1 uses ordinary CREATE and exact approved publication/primary-sale
///      creation bytecode supplied at deployment time. Both code families are
///      hash-bound to this factory generation instead of embedded in runtime.
///
///      Each factory generation also deploys exactly one shared, stateless,
///      non-upgradeable drand evmnet verifier and freezes its identity, provider
///      configuration digest, and runtime code hash as generation provenance.
///
///      This remains FULL_DEPLOYMENT. There is no CREATE2, clone, proxy,
///      initializer, delegatecall, implementation registry, or upgrade path.
contract HellboxPublicationFactory is Ownable2Step, EIP712 {
    // ---------------------------------------------------------------------
    // Version / architecture identity
    // ---------------------------------------------------------------------

    uint256 public constant FACTORY_VERSION = 1;
    uint256 public constant PUBLICATION_VERSION = 1;

    bytes32 public constant TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION");
    bytes32 public constant DEPLOYMENT_MODE = keccak256("FULL_DEPLOYMENT");
    bytes32 public constant PRIMARY_SALE_ID = keccak256("HELLBOX_PRIMARY_SALE_V1");
    uint256 public constant PRIMARY_SALE_VERSION = 1;

    /// @notice Domain separator for the renderer-binding enforcement preimage
    ///         committed by each release as `CommitmentSet.rendererRulesDigest`.
    bytes32 public constant RENDERER_BINDING_ENFORCEMENT_DOMAIN =
        keccak256("HELLBOX_ENFORCEMENT_V1:RENDERER_BINDING");

    /// @notice Stable identifier expected from the one verifier deployed by
    ///         this factory generation.
    bytes32 public constant RANDOMNESS_VERIFIER_ID = keccak256("HELLBOX_DRAND_EVMNET_VERIFIER_V1");

    /// @notice Digest of the exact drand evmnet chain identity, public key,
    ///         schedule, domain, and round-message rules approved for this
    ///         factory generation.
    bytes32 public constant RANDOMNESS_PROVIDER_CONFIG_DIGEST =
        0x0d191efbb2f605bf73b6f3c4819b21bc8c7a64393c6dcfd43b6b2f6b5be401e3;

    /// @notice EIP-712 activation authorization signed by the fresh campaign
    ///         wallet itself. The signature proves control without exposing
    ///         its mnemonic/private key to Harrow, the repository, or chain.
    bytes32 public constant PRIZE_WALLET_ACTIVATION_TYPEHASH = keccak256(
        "PrizeWalletActivation(uint256 generation,address wallet,bytes32 campaignManifestDigest,uint256 deadline)"
    );

    uint8 public constant PRIZE_DEPOSIT_NONE = 0;
    uint8 public constant PRIZE_DEPOSIT_RESERVED = 1;
    uint8 public constant PRIZE_DEPOSIT_COMPLETED = 2;

    /// @notice Exact creation-code hash approved for this factory generation.
    /// @dev Registry/factory provenance only. This is not a ReleaseConfig field,
    ///      does not change HELLBOX_ABI_V1, and is not a universal instance
    ///      runtime hash.
    bytes32 public immutable approvedPublicationCreationCodeHash;

    /// @notice Exact HellboxPrimarySale creation-code hash approved for this
    ///         factory generation. The code is supplied only at deployment, so
    ///         it is not embedded in factory runtime or replaceable afterward.
    bytes32 public immutable approvedPrimarySaleCreationCodeHash;

    /// @notice Inert HellboxBirthPolicyCodeStore selected for this factory
    ///         generation.
    /// @dev Factory-generation provenance only. Publications will copy the
    ///      stored BirthPolicy creation bytes from runtime offset 1 and verify
    ///      them against `approvedBirthPolicyCreationCodeHash` before CREATE.
    ///      This is never caller-selected per publication.
    address public immutable birthPolicyCodeStore;

    /// @notice Exact keccak256 of the HellboxBirthPolicy creation bytes stored
    ///         after runtime offset 1 in `birthPolicyCodeStore`.
    /// @dev Factory-generation provenance only. This does not enter
    ///      ReleaseConfig and does not change HELLBOX_ABI_V1.
    bytes32 public immutable approvedBirthPolicyCreationCodeHash;

    /// @notice Exactly one shared stateless randomness verifier deployed by
    ///         this factory generation.
    /// @dev There is no setter, replacement, proxy, registry switch, or
    ///      per-publication caller-selected verifier path.
    address public immutable randomnessVerifier;

    /// @notice Runtime code hash of `randomnessVerifier`, frozen as factory-
    ///         generation provenance.
    bytes32 public immutable randomnessVerifierRuntimeCodeHash;

    /// @notice Narrow publish-time transport for the three committed
    ///         BirthPolicy enforcement preimages.
    /// @dev This struct intentionally excludes the code-store address/hash,
    ///      which remain immutable factory-generation provenance.
    struct BirthPolicyPreimages {
        bytes fixedCopyPolicyPreimage;
        bytes birthTraitsPolicyPreimage;
        bytes randomizationPolicyPreimage;
    }

    /// @notice Canonical renderer-binding preimage for one release. Its digest
    ///         is frozen at publish time inside `CommitmentSet.rendererRulesDigest`,
    ///         so the renderer, its exact code, its canonical art store and its
    ///         canvas are all settled before any copy is ever issued.
    struct RendererPreimages {
        bytes32 rendererId;
        uint256 rendererVersion;
        uint256 interfaceVersion;
        bytes32 rendererCreationCodeHash;
        address artDataStore;
        bytes32 artDataStoreCodeHash;
        uint256 canvasWidth;
        uint256 canvasHeight;
    }

    /// @notice Public, non-secret record of one prize-wallet campaign
    ///         generation. The wallet remains an ordinary EOA controlled by
    ///         the mnemonic recovered by the puzzle winner; no secret enters
    ///         this contract.
    struct PrizeWalletCampaign {
        address wallet;
        bytes32 campaignManifestDigest;
        uint64 activatedAt;
        uint64 claimedAt;
        uint64 pendingPublicationDeposits;
        uint64 completedPublicationDeposits;
    }

    // ---------------------------------------------------------------------
    // Minimal append-only provenance state
    // ---------------------------------------------------------------------

    mapping(address publication => bool) public isPublication;

    mapping(bytes32 releaseConfigDigest => address publication) public publicationByReleaseDigest;

    mapping(bytes32 publicationKeyHash => address publication) public publicationByKeyHash;

    address[] public publications;

    /// @notice Exactly one permanent primary-sale checkout per publication.
    /// @dev Both directions are append-only. There is no replacement, removal,
    ///      upgrade, or arbitrary module-registry path.
    mapping(address publication => address primarySale) public primarySaleByPublication;
    mapping(address primarySale => address publication) public publicationByPrimarySale;

    mapping(address publication => address renderer) public rendererByPublication;
    mapping(address renderer => address publication) public publicationByRenderer;

    /// @notice Active prize-wallet campaign generation for publications made
    ///         by this factory generation. Zero means no campaign is active.
    uint256 public activePrizeWalletGeneration;

    mapping(uint256 generation => PrizeWalletCampaign campaign) public prizeWalletCampaignByGeneration;

    /// @notice Prevents a campaign EOA from ever being recycled as a later
    ///         prize wallet through this factory generation.
    mapping(address wallet => uint256 generation) public prizeWalletGenerationByAddress;

    /// @notice Prevents accidental reuse of a campaign manifest/commitment.
    mapping(bytes32 campaignManifestDigest => uint256 generation) public prizeWalletGenerationByManifestDigest;

    /// @notice One immutable prize-deposit lifecycle per official publication.
    mapping(address publication => uint256 generation) public prizeWalletDepositGenerationByPublication;
    mapping(address publication => uint8 state) public prizeWalletDepositStateByPublication;

    /// @notice Explicit campaign-generation approval required before an
    ///         official publication may reserve the active Prize Wallet.
    /// @dev Approval may be revoked without affecting a reservation that was
    ///      already created; completion relies on the immutable deposit state.
    mapping(address publication => uint256 generation) public prizeWalletApprovedGenerationByPublication;

    // ---------------------------------------------------------------------
    // Errors
    // ---------------------------------------------------------------------

    error InvalidApprovedPublicationCreationCodeHash();

    error InvalidApprovedPrimarySaleCreationCodeHash();

    error UnofficialPrimarySalePublication(address publication);
    error PrimarySaleAlreadyRegistered(address publication, address primarySale);
    error UnapprovedPrimarySaleCreationCode(bytes32 expectedCreationCodeHash, bytes32 actualCreationCodeHash);
    error PrimarySaleDeploymentProducedNoCode();
    error PrimarySaleIdentityMismatch(bytes32 expectedId, bytes32 actualId);
    error PrimarySaleVersionMismatch(uint256 expectedVersion, uint256 actualVersion);
    error PrimarySalePublicationMismatch(address expectedPublication, address actualPublication);
    error PrimarySaleFactoryMismatch(address expectedFactory, address actualFactory);
    error PrimarySaleChainMismatch(uint256 expectedChainId, uint256 actualChainId);
    error PrimarySaleReleaseDigestMismatch(bytes32 expectedDigest, bytes32 actualDigest);
    error PrimarySaleCommitmentsDigestMismatch(bytes32 expectedDigest, bytes32 actualDigest);

    error UnofficialRendererPublication(address publication);
    error RendererAlreadyRegistered(address publication, address renderer);
    error RendererCommitmentsDigestMismatch(bytes32 expectedDigest, bytes32 actualDigest);
    error RendererRulesDigestMismatch(bytes32 expectedDigest, bytes32 actualDigest);
    error UnapprovedRendererCreationCode(bytes32 expectedCreationCodeHash, bytes32 actualCreationCodeHash);
    error RendererDeploymentProducedNoCode();
    error RendererIdentityMismatch(bytes32 expectedId, bytes32 actualId);
    error RendererVersionMismatch(uint256 expectedVersion, uint256 actualVersion);
    error RendererInterfaceVersionMismatch(uint256 expectedVersion, uint256 actualVersion);
    error RendererArtDataStoreMismatch(address expectedStore, address actualStore);
    error RendererArtDataStoreCodeHashMismatch(bytes32 expectedCodeHash, bytes32 actualCodeHash);
    error RendererCanvasMismatch(uint256 expectedWidth, uint256 expectedHeight, uint256 actualWidth, uint256 actualHeight);

    error InvalidBirthPolicyCodeStore();

    error InvalidApprovedBirthPolicyCreationCodeHash();

    error RandomnessVerifierDeploymentProducedNoCode();

    error RandomnessVerifierIdentityMismatch(bytes32 expectedVerifierId, bytes32 actualVerifierId);

    error RandomnessProviderConfigDigestMismatch(
        bytes32 expectedProviderConfigDigest, bytes32 actualProviderConfigDigest
    );

    error UnapprovedPublicationCreationCode(bytes32 expectedCreationCodeHash, bytes32 actualCreationCodeHash);

    error DuplicateReleaseConfigDigest(bytes32 releaseConfigDigest, address existingPublication);

    error DuplicatePublicationKey(bytes32 publicationKeyHash, address existingPublication);

    error DeploymentFactoryMismatch(address expected, address actual);

    error DeploymentChainMismatch(uint256 expected, uint256 actual);

    error DeploymentTemplateMismatch(bytes32 expected, bytes32 actual);

    error DeploymentPublicationVersionMismatch(uint256 expected, uint256 actual);

    error DeploymentReleaseDigestMismatch(bytes32 expected, bytes32 actual);

    error DeploymentPublicationKeyMismatch(bytes32 expected, bytes32 actual);

    error DeploymentBirthPolicyMissing();
    error DeploymentBirthPolicyPublicationMismatch(address expected, address actual);

    error PrizeWalletManifestDigestMissing();
    error InvalidPrizeWalletAddress(address wallet);
    error PrizeWalletAddressHasCode(address wallet, uint256 codeSize);
    error PrizeWalletAddressAlreadyUsed(address wallet, uint256 generation);
    error PrizeWalletAuthorizationExpired(uint256 deadline, uint256 currentTime);
    error PrizeWalletTimestampOverflow(uint256 timestamp);
    error PrizeWalletActivationSignatureMismatch(address expectedWallet, address recoveredSigner);
    error PrizeWalletCampaignNotActive();
    error PrizeWalletCampaignNotClaimed(uint256 generation);
    error PrizeWalletCampaignAlreadyClaimed(uint256 generation);
    error PrizeWalletCampaignHasPendingDeposits(uint256 generation, uint256 pendingDeposits);
    error PrizeWalletCampaignHasNoCompletedDeposits(uint256 generation);
    error UnauthorizedPrizeWalletClaim(address expectedWallet, address caller);
    error PrizeWalletManifestAlreadyUsed(bytes32 campaignManifestDigest, uint256 generation);
    error PrizeWalletCampaignIntegrityMismatch(uint256 generation);
    error UnauthorizedPrizeWalletPublication(address caller);
    error PrizeWalletPublicationNotApproved(
        address publication, uint256 expectedGeneration, uint256 approvedGeneration
    );
    error PrizeWalletPublicationApprovalAlreadySet(address publication, uint256 generation);
    error PrizeWalletPublicationApprovalMissing(address publication);
    error PrizeWalletDepositAlreadyInitialized(address publication, uint8 state);
    error PrizeWalletDepositNotReserved(address publication, uint8 state);
    error PrizeWalletPendingDepositOverflow(uint256 generation);
    error PrizeWalletPendingDepositUnderflow(uint256 generation);
    error PrizeWalletCompletedDepositOverflow(uint256 generation);
    error OwnershipTransferToPrizeWalletDisabled(address wallet);

    error OwnershipRenunciationDisabled();

    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------

    /// @notice Permanent provenance event for a publication physically created
    ///         by this approved factory.
    /// @dev Block number, timestamp, transaction, and log position are already
    ///      inherent in the chain and are intentionally not duplicated in state.
    ///
    ///      `publisherAuthority` here is the factory publishing authority
    ///      observed for this deployment, not the publication-level operational
    ///      authority stored in HellboxPublication.ReleaseConfig.
    event PublicationPublished(
        address indexed publication,
        bytes32 indexed releaseConfigDigest,
        bytes32 indexed publicationKeyHash,
        address publisherAuthority,
        bytes32 runtimeCodeHash
    );

    /// @notice Permanent provenance for the one exact checkout physically
    ///         created and accepted for an official publication.
    event PrimarySaleDeployed(
        address indexed publication,
        address indexed primarySale,
        bytes32 indexed saleConfigDigest,
        bytes32 runtimeCodeHash
    );

    /// @notice Permanent evidence of the one renderer bound to a publication.
    event RendererDeployed(
        address indexed publication,
        address indexed renderer,
        bytes32 rendererId,
        uint256 rendererVersion,
        uint256 interfaceVersion,
        address artDataStore,
        bytes32 artDataStoreCodeHash,
        bytes32 runtimeCodeHash
    );

    /// @notice Constructor-time provenance for the one verifier shared by all
    ///         publications manufactured by this factory generation.
    event RandomnessVerifierBound(
        address indexed verifier,
        bytes32 indexed verifierId,
        bytes32 indexed providerConfigDigest,
        bytes32 runtimeCodeHash
    );

    event PrizeWalletCampaignActivated(
        uint256 indexed generation, address indexed wallet, bytes32 indexed campaignManifestDigest, uint64 activatedAt
    );

    event PrizeWalletPublicationApproved(address indexed publication, uint256 indexed generation);

    event PrizeWalletPublicationApprovalRevoked(address indexed publication, uint256 indexed generation);

    event PrizeWalletDepositReserved(
        address indexed publication,
        uint256 indexed generation,
        address indexed wallet,
        uint64 pendingPublicationDeposits
    );

    event PrizeWalletDepositCompleted(
        address indexed publication,
        uint256 indexed generation,
        address indexed wallet,
        uint64 pendingPublicationDeposits,
        uint64 completedPublicationDeposits
    );

    event PrizeWalletCampaignClaimed(
        uint256 indexed generation, address indexed wallet, uint64 claimedAt, address indexed confirmer
    );

    // ---------------------------------------------------------------------
    // Construction / authority
    // ---------------------------------------------------------------------

    /// @param initialPublisherAuthority Initial authority allowed to publish new
    ///        Hellbox collections through this factory. This may later rotate
    ///        through Ownable2Step, including to a Safe or other controller.
    /// @param publicationCreationCodeHash keccak256 of the exact reviewed
    ///        HellboxPublication V1 creation bytecode approved for this factory
    ///        generation.
    /// @param primarySaleCreationCodeHash keccak256 of the exact reviewed
    ///        HellboxPrimarySale V1 creation bytecode approved for this factory
    ///        generation.
    /// @param birthPolicyCodeStoreAddress Inert HellboxBirthPolicyCodeStore
    ///        selected for this factory generation. It is intentionally frozen
    ///        here rather than accepted from `publish(...)`.
    /// @param birthPolicyCreationCodeHash keccak256 of the exact
    ///        HellboxBirthPolicy creation bytes stored after runtime offset 1
    ///        in the selected code store.
    constructor(
        address initialPublisherAuthority,
        bytes32 publicationCreationCodeHash,
        bytes32 primarySaleCreationCodeHash,
        address birthPolicyCodeStoreAddress,
        bytes32 birthPolicyCreationCodeHash
    ) Ownable(initialPublisherAuthority) EIP712("HellboxPrizeWalletRegistry", "1") {
        if (publicationCreationCodeHash == bytes32(0)) {
            revert InvalidApprovedPublicationCreationCodeHash();
        }
        if (primarySaleCreationCodeHash == bytes32(0)) {
            revert InvalidApprovedPrimarySaleCreationCodeHash();
        }

        if (birthPolicyCodeStoreAddress == address(0)) {
            revert InvalidBirthPolicyCodeStore();
        }

        if (birthPolicyCreationCodeHash == bytes32(0)) {
            revert InvalidApprovedBirthPolicyCreationCodeHash();
        }

        HellboxDrandEvmnetVerifier deployedVerifier = new HellboxDrandEvmnetVerifier();

        address verifierAddress = address(deployedVerifier);
        if (verifierAddress.code.length == 0) {
            revert RandomnessVerifierDeploymentProducedNoCode();
        }

        IHellboxRandomnessVerifier verifier = IHellboxRandomnessVerifier(verifierAddress);

        bytes32 actualVerifierId = verifier.verifierId();
        if (actualVerifierId != RANDOMNESS_VERIFIER_ID) {
            revert RandomnessVerifierIdentityMismatch(RANDOMNESS_VERIFIER_ID, actualVerifierId);
        }

        bytes32 actualProviderConfigDigest = verifier.providerConfigDigest();

        if (actualProviderConfigDigest != RANDOMNESS_PROVIDER_CONFIG_DIGEST) {
            revert RandomnessProviderConfigDigestMismatch(RANDOMNESS_PROVIDER_CONFIG_DIGEST, actualProviderConfigDigest);
        }

        bytes32 verifierRuntimeCodeHash = verifierAddress.codehash;

        approvedPublicationCreationCodeHash = publicationCreationCodeHash;
        approvedPrimarySaleCreationCodeHash = primarySaleCreationCodeHash;
        birthPolicyCodeStore = birthPolicyCodeStoreAddress;
        approvedBirthPolicyCreationCodeHash = birthPolicyCreationCodeHash;
        randomnessVerifier = verifierAddress;
        randomnessVerifierRuntimeCodeHash = verifierRuntimeCodeHash;

        emit RandomnessVerifierBound(
            verifierAddress, actualVerifierId, actualProviderConfigDigest, verifierRuntimeCodeHash
        );
    }

    /// @notice Ownership renunciation is intentionally disabled so the official
    ///         V1 factory cannot be permanently bricked by an accidental call.
    /// @dev Factory authority may still rotate normally through Ownable2Step.
    function renounceOwnership() public override onlyOwner {
        revert OwnershipRenunciationDisabled();
    }

    /// @notice Prevents the publishing authority from being deliberately or
    ///         accidentally transferred to the currently active prize wallet.
    function transferOwnership(address newOwner) public override onlyOwner {
        if (newOwner != address(0) && prizeWalletGenerationByAddress[newOwner] != 0) {
            revert OwnershipTransferToPrizeWalletDisabled(newOwner);
        }

        super.transferOwnership(newOwner);
    }

    // ---------------------------------------------------------------------
    // Repeating Prize Wallet campaign registry
    // ---------------------------------------------------------------------

    /// @notice Returns the active campaign wallet or zero when no campaign has
    ///         yet been activated. A claimed campaign remains historical but is
    ///         no longer eligible for new publication deposits.
    function activePrizeWallet() public view returns (address wallet) {
        uint256 generation = activePrizeWalletGeneration;
        if (generation == 0) {
            return address(0);
        }

        PrizeWalletCampaign storage campaign = prizeWalletCampaignByGeneration[generation];
        if (campaign.claimedAt != 0) {
            return address(0);
        }

        wallet = campaign.wallet;
    }

    function activePrizeWalletManifestDigest() external view returns (bytes32 campaignManifestDigest) {
        uint256 generation = activePrizeWalletGeneration;
        if (generation == 0) {
            return bytes32(0);
        }

        PrizeWalletCampaign storage campaign = prizeWalletCampaignByGeneration[generation];
        if (campaign.claimedAt != 0) {
            return bytes32(0);
        }

        campaignManifestDigest = campaign.campaignManifestDigest;
    }

    function activePrizeWalletClaimed() external view returns (bool) {
        uint256 generation = activePrizeWalletGeneration;
        return generation != 0 && prizeWalletCampaignByGeneration[generation].claimedAt != 0;
    }

    function activePrizeWalletPendingDeposits() external view returns (uint256) {
        uint256 generation = activePrizeWalletGeneration;
        if (generation == 0) {
            return 0;
        }

        return prizeWalletCampaignByGeneration[generation].pendingPublicationDeposits;
    }

    function isActivePrizeWallet(address wallet) public view returns (bool) {
        uint256 generation = activePrizeWalletGeneration;
        if (generation == 0) {
            return false;
        }

        PrizeWalletCampaign storage campaign = prizeWalletCampaignByGeneration[generation];

        return campaign.wallet == wallet && campaign.claimedAt == 0;
    }

    /// @notice Computes the exact EIP-712 digest a fresh campaign wallet must
    ///         sign before Harrow can activate only its public address.
    function prizeWalletActivationDigest(
        uint256 generation,
        address wallet,
        bytes32 campaignManifestDigest,
        uint256 deadline
    ) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(PRIZE_WALLET_ACTIVATION_TYPEHASH, generation, wallet, campaignManifestDigest, deadline)
            )
        );
    }

    /// @notice Activates a fresh mnemonic-controlled EOA for the next repeating
    ///         prize campaign. The EOA must authorize its own activation by an
    ///         EIP-712 signature; Harrow needs only the public address, manifest
    ///         digest, and signature—not the mnemonic or private key.
    /// @dev Rotation is impossible until the prior wallet proves winner control
    ///      and every already-reserved publication deposit has completed.
    function activatePrizeWalletCampaign(
        address wallet,
        bytes32 campaignManifestDigest,
        uint256 deadline,
        bytes calldata walletSignature
    ) external onlyOwner returns (uint256 generation) {
        if (campaignManifestDigest == bytes32(0)) {
            revert PrizeWalletManifestDigestMissing();
        }
        if (deadline < block.timestamp) {
            revert PrizeWalletAuthorizationExpired(deadline, block.timestamp);
        }

        uint256 currentGeneration = activePrizeWalletGeneration;
        if (currentGeneration != 0) {
            PrizeWalletCampaign storage currentCampaign = prizeWalletCampaignByGeneration[currentGeneration];

            if (currentCampaign.claimedAt == 0) {
                revert PrizeWalletCampaignNotClaimed(currentGeneration);
            }
            if (currentCampaign.pendingPublicationDeposits != 0) {
                revert PrizeWalletCampaignHasPendingDeposits(
                    currentGeneration, currentCampaign.pendingPublicationDeposits
                );
            }
        }

        uint256 usedManifestGeneration = prizeWalletGenerationByManifestDigest[campaignManifestDigest];
        if (usedManifestGeneration != 0) {
            revert PrizeWalletManifestAlreadyUsed(campaignManifestDigest, usedManifestGeneration);
        }

        generation = currentGeneration + 1;
        _validateNewPrizeWallet(wallet);

        bytes32 digest = prizeWalletActivationDigest(generation, wallet, campaignManifestDigest, deadline);
        address recoveredSigner = ECDSA.recover(digest, walletSignature);
        if (recoveredSigner != wallet) {
            revert PrizeWalletActivationSignatureMismatch(wallet, recoveredSigner);
        }

        if (block.timestamp > type(uint64).max) {
            revert PrizeWalletTimestampOverflow(block.timestamp);
        }

        prizeWalletCampaignByGeneration[generation] = PrizeWalletCampaign({
            wallet: wallet,
            campaignManifestDigest: campaignManifestDigest,
            activatedAt: uint64(block.timestamp),
            claimedAt: 0,
            pendingPublicationDeposits: 0,
            completedPublicationDeposits: 0
        });

        prizeWalletGenerationByAddress[wallet] = generation;
        prizeWalletGenerationByManifestDigest[campaignManifestDigest] = generation;
        activePrizeWalletGeneration = generation;

        emit PrizeWalletCampaignActivated(generation, wallet, campaignManifestDigest, uint64(block.timestamp));
    }

    /// @notice Approves one already-registered official publication to reserve
    ///         the currently active Prize Wallet campaign generation.
    /// @dev Approval is explicit and generation-bound. A publication that has
    ///      already reserved or completed its one deposit lifecycle cannot be
    ///      approved again.
    function approvePrizeWalletPublication(address publication) external onlyOwner returns (uint256 generation) {
        if (!isPublication[publication]) {
            revert UnauthorizedPrizeWalletPublication(publication);
        }

        uint8 depositState = prizeWalletDepositStateByPublication[publication];
        if (depositState != PRIZE_DEPOSIT_NONE) {
            revert PrizeWalletDepositAlreadyInitialized(publication, depositState);
        }

        generation = activePrizeWalletGeneration;
        if (generation == 0) {
            revert PrizeWalletCampaignNotActive();
        }

        PrizeWalletCampaign storage campaign = prizeWalletCampaignByGeneration[generation];
        if (campaign.claimedAt != 0) {
            revert PrizeWalletCampaignAlreadyClaimed(generation);
        }
        _validateActivePrizeWalletCampaign(generation, campaign);

        uint256 approvedGeneration = prizeWalletApprovedGenerationByPublication[publication];
        if (approvedGeneration == generation) {
            revert PrizeWalletPublicationApprovalAlreadySet(publication, generation);
        }

        prizeWalletApprovedGenerationByPublication[publication] = generation;

        emit PrizeWalletPublicationApproved(publication, generation);
    }

    /// @notice Revokes permission for a publication to create a new Prize
    ///         Wallet reservation. Any reservation already created remains
    ///         completable so an authority rotation cannot strand the winner.
    function revokePrizeWalletPublicationApproval(address publication) external onlyOwner {
        uint256 generation = prizeWalletApprovedGenerationByPublication[publication];
        if (generation == 0) {
            revert PrizeWalletPublicationApprovalMissing(publication);
        }

        delete prizeWalletApprovedGenerationByPublication[publication];

        emit PrizeWalletPublicationApprovalRevoked(publication, generation);
    }

    /// @notice Claim acknowledgement made directly by the winner-controlled
    ///         recovered prize wallet. This moves no assets. Requiring the
    ///         wallet itself to call prevents an activation-time claim signature
    ///         from being pre-generated and handed to the publisher.
    function confirmPrizeWalletClaim() external {
        uint256 generation = activePrizeWalletGeneration;
        if (generation == 0) {
            revert PrizeWalletCampaignNotActive();
        }

        PrizeWalletCampaign storage campaign = prizeWalletCampaignByGeneration[generation];
        if (msg.sender != campaign.wallet) {
            revert UnauthorizedPrizeWalletClaim(campaign.wallet, msg.sender);
        }

        _confirmPrizeWalletClaim(generation, campaign, msg.sender);
    }

    /// @notice Reserves the currently active unclaimed campaign wallet for one
    ///         official publication's seventh-mint deposit. Only publications
    ///         already manufactured and registered by this factory may call.
    function reserveActivePrizeWalletDeposit()
        external
        returns (uint256 generation, address wallet, bytes32 campaignManifestDigest)
    {
        if (!isPublication[msg.sender]) {
            revert UnauthorizedPrizeWalletPublication(msg.sender);
        }

        uint8 existingState = prizeWalletDepositStateByPublication[msg.sender];
        if (existingState != PRIZE_DEPOSIT_NONE) {
            revert PrizeWalletDepositAlreadyInitialized(msg.sender, existingState);
        }

        generation = activePrizeWalletGeneration;
        if (generation == 0) {
            revert PrizeWalletCampaignNotActive();
        }

        PrizeWalletCampaign storage campaign = prizeWalletCampaignByGeneration[generation];
        if (campaign.claimedAt != 0) {
            revert PrizeWalletCampaignAlreadyClaimed(generation);
        }
        _validateActivePrizeWalletCampaign(generation, campaign);

        uint256 approvedGeneration = prizeWalletApprovedGenerationByPublication[msg.sender];
        if (approvedGeneration != generation) {
            revert PrizeWalletPublicationNotApproved(msg.sender, generation, approvedGeneration);
        }

        if (campaign.pendingPublicationDeposits == type(uint64).max) {
            revert PrizeWalletPendingDepositOverflow(generation);
        }

        ++campaign.pendingPublicationDeposits;
        prizeWalletDepositGenerationByPublication[msg.sender] = generation;
        prizeWalletDepositStateByPublication[msg.sender] = PRIZE_DEPOSIT_RESERVED;

        wallet = campaign.wallet;
        campaignManifestDigest = campaign.campaignManifestDigest;

        emit PrizeWalletDepositReserved(msg.sender, generation, wallet, campaign.pendingPublicationDeposits);
    }

    /// @notice Completes one publication's reserved deposit after its prize copy
    ///         has been minted atomically. The approved publication code is the
    ///         only caller trusted to report this one-way transition.
    function completePrizeWalletDeposit() external {
        if (!isPublication[msg.sender]) {
            revert UnauthorizedPrizeWalletPublication(msg.sender);
        }

        uint8 state = prizeWalletDepositStateByPublication[msg.sender];
        if (state != PRIZE_DEPOSIT_RESERVED) {
            revert PrizeWalletDepositNotReserved(msg.sender, state);
        }

        uint256 generation = prizeWalletDepositGenerationByPublication[msg.sender];
        PrizeWalletCampaign storage campaign = prizeWalletCampaignByGeneration[generation];

        if (campaign.pendingPublicationDeposits == 0) {
            revert PrizeWalletPendingDepositUnderflow(generation);
        }
        if (campaign.completedPublicationDeposits == type(uint64).max) {
            revert PrizeWalletCompletedDepositOverflow(generation);
        }

        --campaign.pendingPublicationDeposits;
        ++campaign.completedPublicationDeposits;
        prizeWalletDepositStateByPublication[msg.sender] = PRIZE_DEPOSIT_COMPLETED;

        emit PrizeWalletDepositCompleted(
            msg.sender,
            generation,
            campaign.wallet,
            campaign.pendingPublicationDeposits,
            campaign.completedPublicationDeposits
        );
    }

    function _validateNewPrizeWallet(address wallet) internal view {
        if (wallet == address(0) || wallet == address(this) || wallet == owner() || wallet == pendingOwner()) {
            revert InvalidPrizeWalletAddress(wallet);
        }

        uint256 codeSize = wallet.code.length;
        if (codeSize != 0) {
            revert PrizeWalletAddressHasCode(wallet, codeSize);
        }

        uint256 usedGeneration = prizeWalletGenerationByAddress[wallet];
        if (usedGeneration != 0) {
            revert PrizeWalletAddressAlreadyUsed(wallet, usedGeneration);
        }
    }

    function _validateActivePrizeWalletCampaign(uint256 generation, PrizeWalletCampaign storage campaign)
        internal
        view
    {
        address wallet = campaign.wallet;
        if (
            wallet == address(0) || prizeWalletGenerationByAddress[wallet] != generation
                || prizeWalletGenerationByManifestDigest[campaign.campaignManifestDigest] != generation
        ) {
            revert PrizeWalletCampaignIntegrityMismatch(generation);
        }

        uint256 codeSize = wallet.code.length;
        if (codeSize != 0) {
            revert PrizeWalletAddressHasCode(wallet, codeSize);
        }
    }

    function _confirmPrizeWalletClaim(uint256 generation, PrizeWalletCampaign storage campaign, address confirmer)
        internal
    {
        if (campaign.claimedAt != 0) {
            revert PrizeWalletCampaignAlreadyClaimed(generation);
        }
        if (campaign.pendingPublicationDeposits != 0) {
            revert PrizeWalletCampaignHasPendingDeposits(generation, campaign.pendingPublicationDeposits);
        }
        if (campaign.completedPublicationDeposits == 0) {
            revert PrizeWalletCampaignHasNoCompletedDeposits(generation);
        }
        if (block.timestamp > type(uint64).max) {
            revert PrizeWalletTimestampOverflow(block.timestamp);
        }

        campaign.claimedAt = uint64(block.timestamp);

        emit PrizeWalletCampaignClaimed(generation, campaign.wallet, campaign.claimedAt, confirmer);
    }

    // ---------------------------------------------------------------------
    // Exact primary-sale deployment and permanent binding
    // ---------------------------------------------------------------------

    /// @notice Physically deploys and permanently binds the one approved
    ///         HellboxPrimarySale for an official publication.
    /// @dev The reviewed creation code is hash-checked before ordinary CREATE.
    ///      Constructor arguments remain release-specific transport. The newly
    ///      created contract must independently report the exact publication,
    ///      factory, chain, and publication commitment identities before either
    ///      append-only lookup is written. Any failure reverts the deployment.
    function deployPrimarySale(
        address publication,
        bytes calldata primarySaleCreationCode,
        bytes calldata constructorArguments
    ) external onlyOwner returns (address primarySale) {
        if (!isPublication[publication]) {
            revert UnofficialPrimarySalePublication(publication);
        }

        address existingSale = primarySaleByPublication[publication];
        if (existingSale != address(0)) {
            revert PrimarySaleAlreadyRegistered(publication, existingSale);
        }

        bytes memory creationCode = primarySaleCreationCode;
        bytes32 actualCreationCodeHash = keccak256(creationCode);
        if (actualCreationCodeHash != approvedPrimarySaleCreationCodeHash) {
            revert UnapprovedPrimarySaleCreationCode(approvedPrimarySaleCreationCodeHash, actualCreationCodeHash);
        }

        bytes memory initCode = bytes.concat(creationCode, constructorArguments);
        assembly ("memory-safe") {
            primarySale := create(0, add(initCode, 0x20), mload(initCode))
            if iszero(primarySale) {
                let size := returndatasize()
                returndatacopy(0, 0, size)
                revert(0, size)
            }
        }

        if (primarySale.code.length == 0) {
            revert PrimarySaleDeploymentProducedNoCode();
        }

        _verifyPrimarySale(publication, primarySale);

        primarySaleByPublication[publication] = primarySale;
        publicationByPrimarySale[primarySale] = publication;

        bytes32 saleConfigDigest = IHellboxPrimarySaleProvenance(primarySale).saleConfigDigest();

        emit PrimarySaleDeployed(publication, primarySale, saleConfigDigest, primarySale.codehash);
    }

    // ---------------------------------------------------------------------
    // Exact renderer deployment and permanent binding
    // ---------------------------------------------------------------------

    /// @notice Physically deploys and permanently binds the one metadata
    ///         renderer a published release already froze.
    /// @dev Unlike the sale and BirthPolicy approvals, a renderer is not
    ///      approved per factory generation. Canonical art, canvas and renderer
    ///      identity are release-specific, so the authority is the publication's
    ///      own frozen `CommitmentSet.rendererRulesDigest`, transported here as
    ///      an ordinary enforcement preimage under the existing doctrine.
    ///
    ///      That is what makes the binding trustworthy rather than merely
    ///      append-only: this factory's owner cannot bind a renderer serving
    ///      different art, a different canvas or a different renderer version
    ///      than the release the collector can already verify. Every value the
    ///      deployed renderer reports is checked against that frozen preimage
    ///      before either lookup is written, and any mismatch reverts.
    ///
    ///      Whether the frozen art-data store itself holds the correct approved
    ///      artwork is a Gate 6 packaging concern; proven here is only that the
    ///      bound renderer is exactly the one the release committed to.
    function deployRenderer(
        address publication,
        HellboxPublication.CommitmentSet calldata commitments,
        RendererPreimages calldata rendererPreimages,
        bytes calldata rendererCreationCode,
        bytes calldata constructorArguments
    ) external onlyOwner returns (address renderer) {
        // Validation and recording live in their own frames: this entry point
        // already carries five parameters, and the legacy (non-IR) pipeline
        // this generation is frozen on has a hard stack budget.
        _validateRendererBinding(publication, commitments, rendererPreimages, rendererCreationCode);

        bytes memory initCode = bytes.concat(rendererCreationCode, constructorArguments);
        assembly ("memory-safe") {
            renderer := create(0, add(initCode, 0x20), mload(initCode))
            if iszero(renderer) {
                let size := returndatasize()
                returndatacopy(0, 0, size)
                revert(0, size)
            }
        }

        if (renderer.code.length == 0) {
            revert RendererDeploymentProducedNoCode();
        }

        _verifyRenderer(renderer, rendererPreimages);
        _recordRendererBinding(publication, renderer, rendererPreimages);
    }

    /// @dev Everything that must hold before any renderer code is deployed.
    function _validateRendererBinding(
        address publication,
        HellboxPublication.CommitmentSet calldata commitments,
        RendererPreimages calldata rendererPreimages,
        bytes calldata rendererCreationCode
    ) internal view {
        if (!isPublication[publication]) {
            revert UnofficialRendererPublication(publication);
        }

        address existingRenderer = rendererByPublication[publication];
        if (existingRenderer != address(0)) {
            revert RendererAlreadyRegistered(publication, existingRenderer);
        }

        bytes32 expectedCommitmentsDigest = HellboxPublication(publication).commitmentsDigest();
        bytes32 actualCommitmentsDigest = keccak256(abi.encode(commitments));
        if (actualCommitmentsDigest != expectedCommitmentsDigest) {
            revert RendererCommitmentsDigestMismatch(expectedCommitmentsDigest, actualCommitmentsDigest);
        }

        bytes32 actualRendererRulesDigest = rendererRulesDigest(rendererPreimages);
        if (actualRendererRulesDigest != commitments.rendererRulesDigest) {
            revert RendererRulesDigestMismatch(commitments.rendererRulesDigest, actualRendererRulesDigest);
        }

        bytes32 actualCreationCodeHash = keccak256(rendererCreationCode);
        if (actualCreationCodeHash != rendererPreimages.rendererCreationCodeHash) {
            revert UnapprovedRendererCreationCode(rendererPreimages.rendererCreationCodeHash, actualCreationCodeHash);
        }
    }

    /// @dev Written only after every frozen value has been proven to match.
    function _recordRendererBinding(
        address publication,
        address renderer,
        RendererPreimages calldata rendererPreimages
    ) internal {
        rendererByPublication[publication] = renderer;
        publicationByRenderer[renderer] = publication;

        emit RendererDeployed(
            publication,
            renderer,
            rendererPreimages.rendererId,
            rendererPreimages.rendererVersion,
            rendererPreimages.interfaceVersion,
            rendererPreimages.artDataStore,
            rendererPreimages.artDataStoreCodeHash,
            renderer.codehash
        );
    }

    /// @notice Canonical renderer-binding enforcement digest for one preimage.
    function rendererRulesDigest(RendererPreimages calldata rendererPreimages) public pure returns (bytes32) {
        return keccak256(abi.encode(RENDERER_BINDING_ENFORCEMENT_DOMAIN, rendererPreimages));
    }

    /// @dev Every reported renderer value must equal the frozen preimage.
    function _verifyRenderer(address renderer, RendererPreimages calldata rendererPreimages) internal view {
        IHellboxRendererProvenance reported = IHellboxRendererProvenance(renderer);

        bytes32 actualId = reported.rendererId();
        if (actualId != rendererPreimages.rendererId) {
            revert RendererIdentityMismatch(rendererPreimages.rendererId, actualId);
        }

        uint256 actualVersion = reported.rendererVersion();
        if (actualVersion != rendererPreimages.rendererVersion) {
            revert RendererVersionMismatch(rendererPreimages.rendererVersion, actualVersion);
        }

        uint256 actualInterfaceVersion = reported.interfaceVersion();
        if (actualInterfaceVersion != rendererPreimages.interfaceVersion) {
            revert RendererInterfaceVersionMismatch(rendererPreimages.interfaceVersion, actualInterfaceVersion);
        }

        address actualStore = reported.artDataStore();
        if (actualStore != rendererPreimages.artDataStore) {
            revert RendererArtDataStoreMismatch(rendererPreimages.artDataStore, actualStore);
        }

        bytes32 actualStoreCodeHash = reported.artDataStoreCodeHash();
        if (actualStoreCodeHash != rendererPreimages.artDataStoreCodeHash) {
            revert RendererArtDataStoreCodeHashMismatch(rendererPreimages.artDataStoreCodeHash, actualStoreCodeHash);
        }

        uint256 actualWidth = reported.canvasWidth();
        uint256 actualHeight = reported.canvasHeight();
        if (actualWidth != rendererPreimages.canvasWidth || actualHeight != rendererPreimages.canvasHeight) {
            revert RendererCanvasMismatch(
                rendererPreimages.canvasWidth, rendererPreimages.canvasHeight, actualWidth, actualHeight
            );
        }
    }

    // ---------------------------------------------------------------------
    // Publication deployment
    // ---------------------------------------------------------------------

    /// @notice Deploys one new HellboxPublication V1 collection from an already
    ///         frozen HELLBOX_ABI_V1 release configuration.
    ///
    /// @dev V1 deliberately uses ordinary CREATE with exact hash-approved
    ///      creation bytecode, not CREATE2, clones, proxies, initializers,
    ///      delegatecall, an implementation registry, or an upgrade mechanism.
    ///
    ///      Keeping publication creation code out of this factory's runtime
    ///      prevents HellboxPublication growth from making the factory itself
    ///      undeployable under EIP-170.
    ///
    ///      The expected release digest must already have been computed against
    ///      this factory address and the current chain ID. HellboxPublication
    ///      independently recomputes and verifies that digest in its constructor.
    ///      The three enforcement preimages are narrow constructor transport only;
    ///      the factory-owned code-store address/hash remain generation immutables.
    function publish(
        HellboxPublication.ReleaseConfig calldata config,
        HellboxPublication.CommitmentSet calldata commitments,
        bytes32 expectedReleaseConfigDigest,
        BirthPolicyPreimages calldata birthPolicyPreimages,
        bytes calldata publicationCreationCode
    ) external onlyOwner returns (address publicationAddress) {
        bytes32 publicationKeyHash = keccak256(bytes(config.publicationKey));

        _rejectDuplicatePublication(publicationKeyHash, expectedReleaseConfigDigest);

        bytes memory creationCode = publicationCreationCode;
        bytes32 actualCreationCodeHash = keccak256(creationCode);

        if (actualCreationCodeHash != approvedPublicationCreationCodeHash) {
            revert UnapprovedPublicationCreationCode(approvedPublicationCreationCodeHash, actualCreationCodeHash);
        }

        publicationAddress =
            _deployPublication(creationCode, config, commitments, expectedReleaseConfigDigest, birthPolicyPreimages);

        HellboxPublication publication = HellboxPublication(publicationAddress);

        _verifyDeployment(publication, publicationKeyHash, expectedReleaseConfigDigest);

        bytes32 runtimeCodeHash = publicationAddress.codehash;

        // Provenance becomes official only after all defensive checks pass.
        isPublication[publicationAddress] = true;

        publicationByReleaseDigest[expectedReleaseConfigDigest] = publicationAddress;

        publicationByKeyHash[publicationKeyHash] = publicationAddress;

        publications.push(publicationAddress);

        emit PublicationPublished(
            publicationAddress, expectedReleaseConfigDigest, publicationKeyHash, owner(), runtimeCodeHash
        );
    }

    /// @notice Number of publications physically deployed and accepted by this
    ///         factory.
    function publicationCount() external view returns (uint256) {
        return publications.length;
    }

    // ---------------------------------------------------------------------
    // Deployment helpers
    // ---------------------------------------------------------------------

    function _rejectDuplicatePublication(bytes32 publicationKeyHash, bytes32 expectedReleaseConfigDigest)
        internal
        view
    {
        address existingByKey = publicationByKeyHash[publicationKeyHash];

        if (existingByKey != address(0)) {
            revert DuplicatePublicationKey(publicationKeyHash, existingByKey);
        }

        address existingByDigest = publicationByReleaseDigest[expectedReleaseConfigDigest];

        if (existingByDigest != address(0)) {
            revert DuplicateReleaseConfigDigest(expectedReleaseConfigDigest, existingByDigest);
        }
    }

    /// @dev Reconstructs exactly the initcode Solidity would use for a normal
    ///      full deployment: reviewed creation bytecode followed by standard ABI
    ///      constructor arguments. CREATE executes from this factory, so the
    ///      publication constructor still records `msg.sender` as the factory.
    function _deployPublication(
        bytes memory creationCode,
        HellboxPublication.ReleaseConfig calldata config,
        HellboxPublication.CommitmentSet calldata commitments,
        bytes32 expectedReleaseConfigDigest,
        BirthPolicyPreimages calldata birthPolicyPreimages
    ) internal returns (address publicationAddress) {
        HellboxPublication.BirthPolicyDeploymentContext memory
            birthPolicyContext =
            HellboxPublication.BirthPolicyDeploymentContext({
                codeStore: birthPolicyCodeStore,
                approvedCreationCodeHash: approvedBirthPolicyCreationCodeHash,
                fixedCopyPolicyPreimage: birthPolicyPreimages.fixedCopyPolicyPreimage,
                birthTraitsPolicyPreimage: birthPolicyPreimages.birthTraitsPolicyPreimage,
                randomizationPolicyPreimage: birthPolicyPreimages.randomizationPolicyPreimage
            });

        bytes memory constructorArguments =
            abi.encode(config, commitments, expectedReleaseConfigDigest, birthPolicyContext);

        bytes memory initCode = bytes.concat(creationCode, constructorArguments);

        assembly ("memory-safe") {
            publicationAddress := create(0, add(initCode, 0x20), mload(initCode))

            if iszero(publicationAddress) {
                let size := returndatasize()
                returndatacopy(0, 0, size)
                revert(0, size)
            }
        }
    }

    function _verifyPrimarySale(address publicationAddress, address primarySaleAddress) internal view {
        IHellboxPrimarySaleProvenance primarySale = IHellboxPrimarySaleProvenance(primarySaleAddress);

        bytes32 actualId = primarySale.PRIMARY_SALE_ID();
        if (actualId != PRIMARY_SALE_ID) {
            revert PrimarySaleIdentityMismatch(PRIMARY_SALE_ID, actualId);
        }

        uint256 actualVersion = primarySale.PRIMARY_SALE_VERSION();
        if (actualVersion != PRIMARY_SALE_VERSION) {
            revert PrimarySaleVersionMismatch(PRIMARY_SALE_VERSION, actualVersion);
        }

        address actualPublication = primarySale.publication();
        if (actualPublication != publicationAddress) {
            revert PrimarySalePublicationMismatch(publicationAddress, actualPublication);
        }

        address actualFactory = primarySale.publicationFactory();
        if (actualFactory != address(this)) {
            revert PrimarySaleFactoryMismatch(address(this), actualFactory);
        }

        uint256 actualChainId = primarySale.releaseChainId();
        if (actualChainId != block.chainid) {
            revert PrimarySaleChainMismatch(block.chainid, actualChainId);
        }

        HellboxPublication publication = HellboxPublication(publicationAddress);
        bytes32 expectedReleaseDigest = publication.releaseConfigDigest();
        bytes32 actualReleaseDigest = primarySale.publicationReleaseConfigDigest();
        if (actualReleaseDigest != expectedReleaseDigest) {
            revert PrimarySaleReleaseDigestMismatch(expectedReleaseDigest, actualReleaseDigest);
        }

        bytes32 expectedCommitmentsDigest = publication.commitmentsDigest();
        bytes32 actualCommitmentsDigest = primarySale.publicationCommitmentsDigest();
        if (actualCommitmentsDigest != expectedCommitmentsDigest) {
            revert PrimarySaleCommitmentsDigestMismatch(expectedCommitmentsDigest, actualCommitmentsDigest);
        }
    }

    // ---------------------------------------------------------------------
    // Defensive provenance verification
    // ---------------------------------------------------------------------

    function _verifyDeployment(
        HellboxPublication publication,
        bytes32 expectedPublicationKeyHash,
        bytes32 expectedReleaseConfigDigest
    ) internal view {
        address reportedFactory = publication.factory();

        if (reportedFactory != address(this)) {
            revert DeploymentFactoryMismatch(address(this), reportedFactory);
        }

        uint256 reportedChainId = publication.releaseChainId();

        if (reportedChainId != block.chainid) {
            revert DeploymentChainMismatch(block.chainid, reportedChainId);
        }

        bytes32 reportedTemplateId = publication.TEMPLATE_ID();

        if (reportedTemplateId != TEMPLATE_ID) {
            revert DeploymentTemplateMismatch(TEMPLATE_ID, reportedTemplateId);
        }

        uint256 reportedPublicationVersion = publication.PUBLICATION_VERSION();

        if (reportedPublicationVersion != PUBLICATION_VERSION) {
            revert DeploymentPublicationVersionMismatch(PUBLICATION_VERSION, reportedPublicationVersion);
        }

        bytes32 reportedReleaseConfigDigest = publication.releaseConfigDigest();

        if (reportedReleaseConfigDigest != expectedReleaseConfigDigest) {
            revert DeploymentReleaseDigestMismatch(expectedReleaseConfigDigest, reportedReleaseConfigDigest);
        }

        bytes32 reportedPublicationKeyHash = keccak256(bytes(publication.publicationKey()));

        if (reportedPublicationKeyHash != expectedPublicationKeyHash) {
            revert DeploymentPublicationKeyMismatch(expectedPublicationKeyHash, reportedPublicationKeyHash);
        }

        address reportedBirthPolicy = publication.birthPolicy();
        if (reportedBirthPolicy == address(0) || reportedBirthPolicy.code.length == 0) {
            revert DeploymentBirthPolicyMissing();
        }

        address reportedBirthPolicyPublication = HellboxBirthPolicy(reportedBirthPolicy).publication();

        if (reportedBirthPolicyPublication != address(publication)) {
            revert DeploymentBirthPolicyPublicationMismatch(address(publication), reportedBirthPolicyPublication);
        }
    }
}
