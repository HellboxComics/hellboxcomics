// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Royalty} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import {HellboxBirthPolicy} from "./HellboxBirthPolicy.sol";

/// @title HellboxPublication
/// @notice Gate 4 V1 publication kernel: constructor-frozen release identity,
///         configuration commitments, ERC-721 ownership baseline, ERC-2981 royalties,
///         and deterministic primary-issuance accounting primitives.
/// @dev This remains an implementation checkpoint, not yet the finished deployable Gate 4 publication.
///      The deterministic candidate pool, immediate-allocation ordering, wallet lifetime accounting,
///      and true-mintout tail boundary are implemented behind internal functions so they can be
///      exercised with deterministic test doubles before a production entropy provider is selected.
///      Canonical enforcement-preimage schemas and the three committed policy-digest anchors are
///      defined, and constructor-time BirthPolicy deployment is wired through an immutable inert
///      code store, and issued copies consume immutable birth MARK/DEFECT identity through
///      that companion atomically with issuance. Public mint phases, pricing/payment
///      enforcement, production randomness, early-close authority, metadata rendering,
///      and later protocols remain to be wired.
contract HellboxPublication is ERC721Royalty {
    // ---------------------------------------------------------------------
    // HELLBOX_ABI_V1 protocol constants
    // ---------------------------------------------------------------------

    uint256 public constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 public constant CONFIG_SCHEMA_VERSION = 1;
    uint256 public constant PUBLICATION_VERSION = 1;

    bytes32 public constant TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION");
    bytes32 public constant RELEASE_CONFIG_DOMAIN =
        keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");

    uint256 public constant TOKEN_ID_START = 1;

    // ---------------------------------------------------------------------
    // Gate 4 enforcement-preimage domains
    // ---------------------------------------------------------------------

    /// @dev These domains version the canonical ABI-encoded preimages that may
    ///      later be supplied at deployment time. They do not change
    ///      HELLBOX_ABI_V1 or CommitmentSet field order.
    bytes32 public constant FIXED_COPY_RULES_ENFORCEMENT_DOMAIN =
        keccak256("HELLBOX_ENFORCEMENT_V1:FIXED_COPY_RULES");
    bytes32 public constant BIRTH_TRAITS_ENFORCEMENT_DOMAIN =
        keccak256("HELLBOX_ENFORCEMENT_V1:BIRTH_TRAITS");
    bytes32 public constant RANDOMIZATION_POLICY_ENFORCEMENT_DOMAIN =
        keccak256("HELLBOX_ENFORCEMENT_V1:RANDOMIZATION_POLICY");

    bytes32 public constant ALLOCATION_CLASS_CREATOR_IMMEDIATE =
        keccak256("CREATOR_IMMEDIATE");
    bytes32 public constant ALLOCATION_CLASS_PUBLIC_RANDOM_POOL =
        keccak256("PUBLIC_RANDOM_POOL");

    bytes32 public constant PRESS_MARK_AXIS_ID = keccak256("PRESS_MARK");
    bytes32 public constant PRESS_DEFECT_AXIS_ID = keccak256("PRESS_DEFECT");

    // ---------------------------------------------------------------------
    // Frozen constructor configuration
    // ---------------------------------------------------------------------

    struct ReleaseConfig {
        string publicationKey;
        string collectionName;
        string collectionSymbol;

        uint256 maxSupply;
        uint256 primaryLifetimeCap;
        uint256 maxPerTransaction;

        address immediateCreatorRecipient;
        uint256 immediateCreatorCount;

        address tailRecipient;
        uint256 tailReserveCount;

        address royaltyReceiver;
        uint96 royaltyBps;

        address publisherAuthority;

        bool readerEnabled;
        bool sealEnabled;
        bool archiveCompatible;
        bool dynamicMetadataEnabled;
        bool erc6551Compatible;
        bool rewardsCompatible;
        bool hellforgeCompatible;
        bool contextualTraitsEnabled;
    }

    /// @notice Versioned sub-commitments covering rich release data kept outside
    ///         direct contract storage.
    /// @dev HELLBOX_ABI_V1 commits this exact field order. Do not reorder or
    ///      reinterpret these fields without a new commitment/config version.
    struct CommitmentSet {
        bytes32 publicationManifestDigest;
        bytes32 packageDigest;
        bytes32 fixedCopyRulesDigest;
        bytes32 birthTraitsDigest;
        bytes32 randomizationPolicyDigest;
        bytes32 rendererRulesDigest;
        bytes32 readerPolicyDigest;
        bytes32 pricingPoliciesDigest;
        bytes32 paymentRoutesDigest;
        bytes32 mintPhasesDigest;
        bytes32 royaltyPolicyDigest;
        bytes32 treasuryPolicyDigest;
        bytes32 metadataPolicyDigest;
        bytes32 capabilityPolicyDigest;
        bytes32 protocolCompatibilityDigest;
        bytes32 closurePolicyDigest;
        bytes32 authorityPolicyDigest;
        bytes32 eventPolicyDigest;
    }

    // ---------------------------------------------------------------------
    // Canonical deployment-time enforcement preimages
    // ---------------------------------------------------------------------

    /// @notice One fixed-copy rule whose canonical ABI encoding can be
    ///         committed by fixedCopyRulesDigest.
    /// @dev Zero requiredMarkCode / requiredDefectCode means that axis is not
    ///      fixed by this row. Rich human labels/art references remain covered
    ///      by the package/publication commitments rather than duplicated here.
    struct FixedCopyRuleEnforcement {
        uint256 copyId;
        bytes32 allocationClass;
        bytes32 requiredMarkCode;
        bytes32 requiredDefectCode;
        address recipient;
        bool publicRandomPoolEligible;
        bytes32 reasonCode;
    }

    struct FixedCopyRulesEnforcement {
        bool enabled;
        FixedCopyRuleEnforcement[] rules;
    }

    struct BirthTraitValueEnforcement {
        bytes32 code;
        uint256 count;
    }

    /// @notice Enforcement subset for one birth-trait axis.
    /// @dev assignmentMode / overlapPolicy are stable machine codes committed
    ///      by this preimage. Collector-facing labels/layers remain in the
    ///      richer committed package manifests.
    struct BirthTraitAxisEnforcement {
        bytes32 axisId;
        bytes32 assignmentMode;
        bytes32 overlapPolicy;
        BirthTraitValueEnforcement[] values;
    }

    struct BirthTraitsEnforcement {
        bool enabled;
        BirthTraitAxisEnforcement[] axes;
    }

    /// @notice Deterministic randomization-policy boundary committed by
    ///         randomizationPolicyDigest.
    /// @dev Provider-specific details remain nested behind providerConfigDigest
    ///      until the production entropy mechanism is selected and frozen.
    struct RandomizationPolicyEnforcement {
        bool enabled;
        bytes32 policyId;
        uint256 schemeVersion;
        bytes32 providerConfigDigest;
        bytes32 copyShuffleMode;
        bytes32 fixedIdExclusionsDigest;
        bytes32 traitPoolMode;
        bool markDefectIndependent;
        bytes32 creatorDefectFairness;
        bytes32 publisherMapKnowledgePolicy;
        bytes32 assignmentProofMode;
    }

    /// @notice Narrow constructor-only transport for the factory-generation
    ///         BirthPolicy infrastructure and the three committed enforcement
    ///         preimages.
    /// @dev The official factory constructs this context from its own immutable
    ///      code-store provenance plus publish-time preimages. It is not part of
    ///      HELLBOX_ABI_V1 and does not alter ReleaseConfig or CommitmentSet.
    struct BirthPolicyDeploymentContext {
        address codeStore;
        bytes32 approvedCreationCodeHash;
        bytes fixedCopyPolicyPreimage;
        bytes birthTraitsPolicyPreimage;
        bytes randomizationPolicyPreimage;
    }

    string public publicationKey;

    uint256 public immutable releaseChainId;
    address public immutable factory;

    uint256 public immutable maxSupply;
    uint256 public immutable primaryLifetimeCap;
    uint256 public immutable maxPerTransaction;

    address public immutable immediateCreatorRecipient;
    uint256 public immutable immediateCreatorCount;

    address public immutable tailRecipient;
    uint256 public immutable tailReserveCount;

    address public immutable royaltyReceiver;
    uint96 public immutable royaltyBps;

    address public immutable publisherAuthority;

    bool public immutable readerEnabled;
    bool public immutable sealEnabled;
    bool public immutable archiveCompatible;
    bool public immutable dynamicMetadataEnabled;
    bool public immutable erc6551Compatible;
    bool public immutable rewardsCompatible;
    bool public immutable hellforgeCompatible;
    bool public immutable contextualTraitsEnabled;

    bytes32 public immutable publicationManifestDigest;
    bytes32 public immutable packageDigest;

    /// @notice Exact policy commitments already bound by HELLBOX_ABI_V1.
    /// @dev Stored individually because later deployment-time enforcement must
    ///      compare canonical preimages against these frozen values.
    bytes32 public immutable fixedCopyRulesDigest;
    bytes32 public immutable birthTraitsDigest;
    bytes32 public immutable randomizationPolicyDigest;

    bytes32 public immutable commitmentsDigest;
    bytes32 public immutable releaseConfigDigest;

    /// @notice Exactly one constructor-created HellboxBirthPolicy companion.
    /// @dev Immutable by design: no setter, replacement, proxy, initializer,
    ///      or post-deployment activation path exists.
    address public immutable birthPolicy;

    bool public immutable configFrozen;
    uint256 public immutable frozenAtBlock;
    uint256 public immutable frozenAtTimestamp;

    // ---------------------------------------------------------------------
    // Deterministic issuance-state checkpoint
    // ---------------------------------------------------------------------

    /// @notice Actual primary tokens minted so far across creator, non-tail,
    ///         and eventual tail issuance.
    uint256 public totalPrimaryIssued;

    /// @notice Number of copy IDs still eligible in the random candidate pool.
    /// @dev After verified standard-native immediate-copy reservation this is 210.
    uint256 public candidatePoolRemaining;

    /// @notice Remaining normal/non-tail primary issuance capacity.
    /// @dev After verified standard-native immediate-copy reservation this is 207.
    uint256 public nonTailIssuanceRemaining;

    uint256 public immediateCreatorIssued;
    uint256 public tailAwardedCount;

    /// @notice True only after a verified fixed-copy policy has bootstrapped
    ///         the candidate pool through _initializeIssuanceState.
    bool public issuanceStateInitialized;

    /// @notice Normal non-tail issuance cannot proceed until all committed
    ///         immediate creator copies have actually been issued.
    bool public immediateCreatorAllocationComplete;

    /// @notice Permanent normal-primary closure state.
    /// @dev This checkpoint sets it on true mint-out. The separate early-close
    ///      authority/mechanism remains intentionally unwired.
    bool public primaryIssuanceClosed;

    /// @notice Distinguishes actual non-tail exhaustion from any future early
    ///         permanent-close path so the Harrow tail can never be swept early.
    bool public trueMintOutReached;

    /// @notice Becomes true exactly once when a configured true-mintout tail is
    ///         issued to the frozen tail recipient.
    bool public tailAwarded;

    /// @notice Lifetime primary usage never decreases on transfer or burn.
    mapping(address account => uint256 used) public walletLifetimePrimaryUsed;

    /// @notice Copy IDs committed to the immediate creator allocation.
    mapping(uint256 tokenId => bool reserved) public isImmediateCreatorCopy;

    /// @notice Whether a reserved immediate creator copy has been issued.
    mapping(uint256 tokenId => bool issued) public immediateCreatorCopyIssued;

    // Sparse Fisher-Yates candidate pool. Copy IDs are conceptually 1..maxSupply.
    // Storage is written only when a position/token departs from its default.
    mapping(uint256 index => uint256 tokenId) private _candidateValueByIndex;
    mapping(uint256 tokenId => uint256 indexPlusOne) private _candidateIndexPlusOne;
    mapping(uint256 tokenId => bool consumed) private _candidateConsumed;

    // ---------------------------------------------------------------------
    // Errors
    // ---------------------------------------------------------------------

    error InvalidPublicationKey();
    error InvalidCollectionNameLength(uint256 byteLength);
    error InvalidCollectionSymbol();
    error InvalidMaxSupply();
    error InvalidPrimaryLifetimeCap(uint256 cap, uint256 supply);
    error InvalidMaxPerTransaction(uint256 maxPerTransaction, uint256 lifetimeCap);
    error InvalidCreatorAllocation(
        uint256 immediateCreatorCount,
        uint256 tailReserveCount,
        uint256 supply
    );
    error InvalidImmediateCreatorRecipient();
    error InvalidTailRecipient();
    error InvalidRoyaltyConfiguration(address receiver, uint96 bps);
    error InvalidPublisherAuthority();
    error InvalidCapabilityConfiguration();
    error MissingRequiredCommitment();
    error ReleaseConfigDigestMismatch(bytes32 expected, bytes32 computed);
    error FixedCopyRulesDigestMismatch(bytes32 expected, bytes32 computed);
    error BirthTraitsDigestMismatch(bytes32 expected, bytes32 computed);
    error RandomizationPolicyDigestMismatch(bytes32 expected, bytes32 computed);
    error InvalidBirthPolicyCodeStore(address codeStore, uint256 runtimeCodeSize);
    error InvalidBirthPolicyCodeStorePrefix(address codeStore, uint8 actualPrefix);
    error BirthPolicyCreationCodeHashMismatch(bytes32 expected, bytes32 computed);
    error BirthPolicyDeploymentProducedNoCode();

    error IssuanceStateAlreadyInitialized();
    error IssuanceStateNotInitialized();
    error InvalidImmediateCreatorCopySet(uint256 expected, uint256 actual);
    error ImmediateCreatorCopyPolicyMismatch(
        uint256 index,
        uint256 expectedTokenId,
        uint256 suppliedTokenId
    );
    error InvalidCopyId(uint256 tokenId);
    error DuplicateImmediateCreatorCopy(uint256 tokenId);
    error CandidateCopyUnavailable(uint256 tokenId);
    error CandidateIndexOutOfRange(uint256 index, uint256 remaining);
    error CandidateAccountingInvariant(
        uint256 candidateRemaining,
        uint256 nonTailRemaining,
        uint256 tailReserve
    );
    error ImmediateCreatorCopyNotReserved(uint256 tokenId);
    error ImmediateCreatorCopyAlreadyIssued(uint256 tokenId);
    error ImmediateCreatorAllocationAlreadyComplete();
    error ImmediateCreatorAllocationIncomplete(uint256 issued, uint256 required);
    error PrimaryIssuanceClosed();
    error NonTailIssuanceExhausted();
    error InvalidPrimaryAccount();
    error InvalidPrimaryRecipient();
    error PrimaryLifetimeCapExceeded(address account, uint256 used, uint256 cap);
    error TailNotConfigured();
    error TailNotReady();
    error TailAlreadyAwarded();
    error TailCandidateInvariant(uint256 remaining, uint256 required);
    error PrimarySupplyInvariant(uint256 issued, uint256 supply);
    error BirthInventoryAccountingInvariant(
        bytes32 axisId,
        uint256 inventoryRemaining,
        uint256 expectedRemaining
    );

    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------

    /// @notice Permanent provenance anchor emitted when constructor validation
    ///         and HELLBOX_ABI_V1 digest verification succeed.
    event PublicationConfigured(
        bytes32 indexed releaseConfigDigest,
        string publicationKey,
        uint256 indexed chainId,
        address indexed factory,
        uint256 publicationVersion,
        bytes32 publicationManifestDigest,
        bytes32 packageDigest
    );

    /// @notice Emitted only after immediate copy IDs have been removed from the
    ///         candidate pool by a caller that has already verified the frozen
    ///         fixed-copy policy preimage.
    event IssuanceStateInitialized(
        uint256 candidatePoolRemaining,
        uint256 nonTailIssuanceRemaining,
        uint256 immediateCreatorCount,
        uint256 tailReserveCount
    );

    event ImmediateCreatorCopyIssued(
        uint256 indexed tokenId,
        address indexed recipient,
        uint256 issuedCount
    );

    event NonTailPrimaryIssued(
        address indexed primaryAccount,
        address indexed recipient,
        uint256 indexed tokenId,
        uint256 walletLifetimeUsed,
        uint256 candidatePoolRemaining,
        uint256 nonTailIssuanceRemaining
    );

    event TrueMintOutReached(uint256 tailCandidateCount);

    event TailCopyIssued(
        uint256 indexed tokenId,
        address indexed recipient,
        uint256 awardedCount
    );

    event TailAwarded(address indexed recipient, uint256 count);

    // ---------------------------------------------------------------------
    // Construction / freeze boundary
    // ---------------------------------------------------------------------

    constructor(
        ReleaseConfig memory config,
        CommitmentSet memory commitments,
        bytes32 expectedReleaseConfigDigest,
        BirthPolicyDeploymentContext memory birthPolicyContext
    ) ERC721(config.collectionName, config.collectionSymbol) {
        _validateReleaseConfig(config, commitments);

        uint256 chainId_ = block.chainid;
        address factory_ = msg.sender;

        bytes32 commitmentsDigest_ = keccak256(abi.encode(commitments));
        bytes32 computedReleaseConfigDigest = _computeReleaseConfigDigest(
            chainId_,
            factory_,
            config,
            commitments
        );

        if (computedReleaseConfigDigest != expectedReleaseConfigDigest) {
            revert ReleaseConfigDigestMismatch(
                expectedReleaseConfigDigest,
                computedReleaseConfigDigest
            );
        }

        publicationKey = config.publicationKey;

        releaseChainId = chainId_;
        factory = factory_;

        maxSupply = config.maxSupply;
        primaryLifetimeCap = config.primaryLifetimeCap;
        maxPerTransaction = config.maxPerTransaction;

        immediateCreatorRecipient = config.immediateCreatorRecipient;
        immediateCreatorCount = config.immediateCreatorCount;

        tailRecipient = config.tailRecipient;
        tailReserveCount = config.tailReserveCount;

        royaltyReceiver = config.royaltyReceiver;
        royaltyBps = config.royaltyBps;

        publisherAuthority = config.publisherAuthority;

        readerEnabled = config.readerEnabled;
        sealEnabled = config.sealEnabled;
        archiveCompatible = config.archiveCompatible;
        dynamicMetadataEnabled = config.dynamicMetadataEnabled;
        erc6551Compatible = config.erc6551Compatible;
        rewardsCompatible = config.rewardsCompatible;
        hellforgeCompatible = config.hellforgeCompatible;
        contextualTraitsEnabled = config.contextualTraitsEnabled;

        publicationManifestDigest = commitments.publicationManifestDigest;
        packageDigest = commitments.packageDigest;
        fixedCopyRulesDigest = commitments.fixedCopyRulesDigest;
        birthTraitsDigest = commitments.birthTraitsDigest;
        randomizationPolicyDigest = commitments.randomizationPolicyDigest;
        commitmentsDigest = commitmentsDigest_;
        releaseConfigDigest = computedReleaseConfigDigest;

        birthPolicy = _deployBirthPolicy(
            config,
            commitments,
            birthPolicyContext
        );

        configFrozen = true;
        frozenAtBlock = block.number;
        frozenAtTimestamp = block.timestamp;

        if (config.royaltyBps > 0) {
            _setDefaultRoyalty(config.royaltyReceiver, config.royaltyBps);
        }

        emit PublicationConfigured(
            computedReleaseConfigDigest,
            config.publicationKey,
            chainId_,
            factory_,
            PUBLICATION_VERSION,
            commitments.publicationManifestDigest,
            commitments.packageDigest
        );
    }

    // ---------------------------------------------------------------------
    // Constructor-only BirthPolicy deployment
    // ---------------------------------------------------------------------

    /// @dev Copies only code-store runtime bytes [1..], verifies that exact
    ///      payload against factory-generation provenance, appends the canonical
    ///      HellboxBirthPolicy constructor arguments, and executes ordinary
    ///      CREATE from this publication. Any failure reverts this publication
    ///      construction atomically.
    function _deployBirthPolicy(
        ReleaseConfig memory config,
        CommitmentSet memory commitments,
        BirthPolicyDeploymentContext memory context
    ) internal returns (address policyAddress) {
        bytes memory creationCode = _copyApprovedBirthPolicyCreationCode(
            context.codeStore,
            context.approvedCreationCodeHash
        );

        HellboxBirthPolicy.PublicationBinding memory binding =
            HellboxBirthPolicy.PublicationBinding({
                maxSupply: config.maxSupply,
                immediateCreatorRecipient: config.immediateCreatorRecipient,
                immediateCreatorCount: config.immediateCreatorCount,
                tailReserveCount: config.tailReserveCount,
                fixedCopyRulesDigest: commitments.fixedCopyRulesDigest,
                birthTraitsDigest: commitments.birthTraitsDigest,
                randomizationPolicyDigest: commitments.randomizationPolicyDigest
            });

        bytes memory constructorArguments = abi.encode(
            binding,
            context.fixedCopyPolicyPreimage,
            context.birthTraitsPolicyPreimage,
            context.randomizationPolicyPreimage
        );

        bytes memory initCode = bytes.concat(
            creationCode,
            constructorArguments
        );

        assembly ("memory-safe") {
            policyAddress := create(
                0,
                add(initCode, 0x20),
                mload(initCode)
            )

            if iszero(policyAddress) {
                let size := returndatasize()
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }

        if (policyAddress.code.length == 0) {
            revert BirthPolicyDeploymentProducedNoCode();
        }
    }

    function _copyApprovedBirthPolicyCreationCode(
        address codeStore,
        bytes32 approvedCreationCodeHash
    ) internal view returns (bytes memory creationCode) {
        uint256 runtimeCodeSize = codeStore.code.length;

        if (
            codeStore == address(0) ||
            approvedCreationCodeHash == bytes32(0) ||
            runtimeCodeSize <= 1
        ) {
            revert InvalidBirthPolicyCodeStore(
                codeStore,
                runtimeCodeSize
            );
        }

        uint256 prefix;
        assembly ("memory-safe") {
            extcodecopy(codeStore, 0x00, 0, 1)
            prefix := byte(0, mload(0x00))
        }

        if (prefix != 0) {
            revert InvalidBirthPolicyCodeStorePrefix(
                codeStore,
                uint8(prefix)
            );
        }

        uint256 creationCodeLength = runtimeCodeSize - 1;
        creationCode = new bytes(creationCodeLength);

        assembly ("memory-safe") {
            extcodecopy(
                codeStore,
                add(creationCode, 0x20),
                1,
                creationCodeLength
            )
        }

        bytes32 actualCreationCodeHash = keccak256(creationCode);
        if (actualCreationCodeHash != approvedCreationCodeHash) {
            revert BirthPolicyCreationCodeHashMismatch(
                approvedCreationCodeHash,
                actualCreationCodeHash
            );
        }
    }

    // ---------------------------------------------------------------------
    // Public commitment helpers
    // ---------------------------------------------------------------------

    /// @notice Computes the aggregate digest of the exact HELLBOX_ABI_V1
    ///         CommitmentSet field order.
    function computeCommitmentsDigest(
        CommitmentSet calldata commitments
    ) external pure returns (bytes32) {
        return keccak256(abi.encode(commitments));
    }

    /// @notice Computes a HELLBOX_ABI_V1 release digest for cross-language
    ///         verification and golden test vectors.
    /// @dev Constructor deployment uses actual block.chainid and actual msg.sender.
    function computeReleaseConfigDigest(
        uint256 chainId,
        address factoryAddress,
        ReleaseConfig calldata config,
        CommitmentSet calldata commitments
    ) external pure returns (bytes32) {
        return
            _computeReleaseConfigDigest(
                chainId,
                factoryAddress,
                config,
                commitments
            );
    }

    // ---------------------------------------------------------------------
    // Deterministic issuance-state views / internal primitives
    // ---------------------------------------------------------------------

    /// @notice Returns whether a copy ID is currently in the candidate pool.
    /// @dev False before issuance bootstrap. Immediate reserved copies and
    ///      already drawn/awarded copies return false.
    function isCandidateCopyAvailable(
        uint256 tokenId
    ) external view returns (bool) {
        if (
            !issuanceStateInitialized ||
            tokenId < TOKEN_ID_START ||
            tokenId > maxSupply ||
            _candidateConsumed[tokenId]
        ) {
            return false;
        }

        uint256 storedIndexPlusOne = _candidateIndexPlusOne[tokenId];
        uint256 index = storedIndexPlusOne == 0
            ? tokenId - TOKEN_ID_START
            : storedIndexPlusOne - 1;

        return
            index < candidatePoolRemaining &&
            _candidateTokenAt(index) == tokenId;
    }

    /// @dev Bootstraps the sparse candidate pool after the caller has verified
    ///      the committed fixed-copy-rule preimage. This function is INTERNAL
    ///      on purpose: the production publication must not expose a post-
    ///      deployment configuration window.
    ///
    ///      The final Gate 4 deployment path will call this only from an
    ///      immutable deployment-time policy path. Deterministic test harnesses
    ///      may call it from their constructor/setup to prove the state machine.
    function _initializeIssuanceState(
        uint256[] memory immediateCopyIds
    ) internal {
        if (issuanceStateInitialized) {
            revert IssuanceStateAlreadyInitialized();
        }

        uint256 immediateCount = immediateCopyIds.length;
        if (immediateCount != immediateCreatorCount) {
            revert InvalidImmediateCreatorCopySet(
                immediateCreatorCount,
                immediateCount
            );
        }

        candidatePoolRemaining = maxSupply;

        HellboxBirthPolicy policy = HellboxBirthPolicy(birthPolicy);

        for (uint256 i = 0; i < immediateCount; ++i) {
            uint256 tokenId = immediateCopyIds[i];
            _validateCopyId(tokenId);

            if (isImmediateCreatorCopy[tokenId]) {
                revert DuplicateImmediateCreatorCopy(tokenId);
            }

            uint256 expectedTokenId = policy.policyImmediateCopyAt(i);
            if (tokenId != expectedTokenId) {
                revert ImmediateCreatorCopyPolicyMismatch(
                    i,
                    expectedTokenId,
                    tokenId
                );
            }

            isImmediateCreatorCopy[tokenId] = true;
            _removeCandidateByTokenId(tokenId);
        }

        nonTailIssuanceRemaining =
            maxSupply -
            immediateCreatorCount -
            tailReserveCount;

        immediateCreatorAllocationComplete = immediateCreatorCount == 0;
        issuanceStateInitialized = true;

        _assertOpenCandidateAccounting();
        _assertBirthInventoryAccounting();

        emit IssuanceStateInitialized(
            candidatePoolRemaining,
            nonTailIssuanceRemaining,
            immediateCreatorCount,
            tailReserveCount
        );
    }

    /// @dev Issues one previously verified immediate creator copy. The copy ID
    ///      must already have been removed from candidate eligibility during
    ///      issuance bootstrap. `entropyWord` is an input boundary only; the
    ///      final production entropy provider remains deliberately open.
    function _issueImmediateCreatorCopy(
        uint256 tokenId,
        uint256 entropyWord
    ) internal {
        _requireIssuanceStateInitialized();

        if (immediateCreatorAllocationComplete) {
            revert ImmediateCreatorAllocationAlreadyComplete();
        }
        if (!isImmediateCreatorCopy[tokenId]) {
            revert ImmediateCreatorCopyNotReserved(tokenId);
        }
        if (immediateCreatorCopyIssued[tokenId]) {
            revert ImmediateCreatorCopyAlreadyIssued(tokenId);
        }

        _assertPrimarySupplyAvailable();

        _assignBirthIdentity(tokenId, entropyWord);

        immediateCreatorCopyIssued[tokenId] = true;
        ++immediateCreatorIssued;
        ++totalPrimaryIssued;

        if (immediateCreatorIssued == immediateCreatorCount) {
            immediateCreatorAllocationComplete = true;
        }

        _assertBirthInventoryAccounting();

        _safeMint(immediateCreatorRecipient, tokenId);

        emit ImmediateCreatorCopyIssued(
            tokenId,
            immediateCreatorRecipient,
            immediateCreatorIssued
        );
    }

    /// @dev Deterministic non-tail issuance primitive. `entropyWord` is an
    ///      input boundary only; this contract intentionally does not decide
    ///      the production entropy provider yet.
    ///
    ///      `primaryAccount` is the wallet whose lifetime primary allowance is
    ///      consumed. `recipient` is the ERC-721 recipient. A later frozen phase
    ///      policy decides whether those addresses may differ.
    function _issueNonTailPrimary(
        address primaryAccount,
        address recipient,
        uint256 entropyWord
    ) internal returns (uint256 tokenId) {
        _requireIssuanceStateInitialized();

        if (!immediateCreatorAllocationComplete) {
            revert ImmediateCreatorAllocationIncomplete(
                immediateCreatorIssued,
                immediateCreatorCount
            );
        }
        if (primaryIssuanceClosed) {
            revert PrimaryIssuanceClosed();
        }
        if (nonTailIssuanceRemaining == 0) {
            revert NonTailIssuanceExhausted();
        }
        if (primaryAccount == address(0)) {
            revert InvalidPrimaryAccount();
        }
        if (recipient == address(0)) {
            revert InvalidPrimaryRecipient();
        }

        uint256 used = walletLifetimePrimaryUsed[primaryAccount];
        if (used >= primaryLifetimeCap) {
            revert PrimaryLifetimeCapExceeded(
                primaryAccount,
                used,
                primaryLifetimeCap
            );
        }

        _assertOpenCandidateAccounting();
        _assertPrimarySupplyAvailable();

        uint256 candidateIndex = _uniformIndex(
            entropyWord,
            candidatePoolRemaining
        );
        tokenId = _removeCandidateAtIndex(candidateIndex);
        _assignBirthIdentity(tokenId, entropyWord);

        walletLifetimePrimaryUsed[primaryAccount] = used + 1;
        --nonTailIssuanceRemaining;
        ++totalPrimaryIssued;

        _assertOpenCandidateAccounting();
        _assertBirthInventoryAccounting();

        if (nonTailIssuanceRemaining == 0) {
            if (candidatePoolRemaining != tailReserveCount) {
                revert TailCandidateInvariant(
                    candidatePoolRemaining,
                    tailReserveCount
                );
            }

            trueMintOutReached = true;
            primaryIssuanceClosed = true;
        }

        _safeMint(recipient, tokenId);

        emit NonTailPrimaryIssued(
            primaryAccount,
            recipient,
            tokenId,
            used + 1,
            candidatePoolRemaining,
            nonTailIssuanceRemaining
        );

        if (trueMintOutReached) {
            emit TrueMintOutReached(candidatePoolRemaining);
        }
    }

    /// @dev Awards the literal final candidate set after true non-tail mint-out.
    ///      No tail IDs are preselected. This function deliberately has no
    ///      external authority endpoint in this checkpoint.
    function _awardTailAfterTrueMintOut(
        uint256 entropyWord
    ) internal {
        _requireIssuanceStateInitialized();

        if (tailReserveCount == 0) {
            revert TailNotConfigured();
        }
        if (tailAwarded) {
            revert TailAlreadyAwarded();
        }
        if (
            !trueMintOutReached ||
            !primaryIssuanceClosed ||
            nonTailIssuanceRemaining != 0
        ) {
            revert TailNotReady();
        }
        if (!immediateCreatorAllocationComplete) {
            revert ImmediateCreatorAllocationIncomplete(
                immediateCreatorIssued,
                immediateCreatorCount
            );
        }
        if (candidatePoolRemaining != tailReserveCount) {
            revert TailCandidateInvariant(
                candidatePoolRemaining,
                tailReserveCount
            );
        }

        // Lock the one-time transition before any ERC721Receiver callback.
        // A revert during a mint rolls the entire transaction/state back.
        tailAwarded = true;

        uint256 tailCount = tailReserveCount;
        for (uint256 i = 0; i < tailCount; ++i) {
            _assertPrimarySupplyAvailable();

            // Every remaining candidate goes to the same frozen tail recipient,
            // so selection order no longer affects collector fairness.
            uint256 tokenId = _removeCandidateAtIndex(0);
            _assignBirthIdentity(tokenId, entropyWord);

            ++tailAwardedCount;
            ++totalPrimaryIssued;

            _assertBirthInventoryAccounting();

            _safeMint(tailRecipient, tokenId);

            emit TailCopyIssued(
                tokenId,
                tailRecipient,
                tailAwardedCount
            );
        }

        if (
            candidatePoolRemaining != 0 ||
            totalPrimaryIssued != maxSupply
        ) {
            revert PrimarySupplyInvariant(
                totalPrimaryIssued,
                maxSupply
            );
        }

        emit TailAwarded(tailRecipient, tailAwardedCount);
    }

    function _removeCandidateByTokenId(
        uint256 tokenId
    ) internal returns (uint256 removedTokenId) {
        _validateCopyId(tokenId);

        if (_candidateConsumed[tokenId]) {
            revert CandidateCopyUnavailable(tokenId);
        }

        uint256 storedIndexPlusOne = _candidateIndexPlusOne[tokenId];
        uint256 candidateIndex = storedIndexPlusOne == 0
            ? tokenId - TOKEN_ID_START
            : storedIndexPlusOne - 1;

        if (
            candidateIndex >= candidatePoolRemaining ||
            _candidateTokenAt(candidateIndex) != tokenId
        ) {
            revert CandidateCopyUnavailable(tokenId);
        }

        return _removeCandidateAtIndex(candidateIndex);
    }

    function _removeCandidateAtIndex(
        uint256 candidateIndex
    ) internal returns (uint256 tokenId) {
        uint256 remaining = candidatePoolRemaining;
        if (remaining == 0 || candidateIndex >= remaining) {
            revert CandidateIndexOutOfRange(
                candidateIndex,
                remaining
            );
        }

        uint256 lastIndex = remaining - 1;
        tokenId = _candidateTokenAt(candidateIndex);
        uint256 lastTokenId = _candidateTokenAt(lastIndex);

        _candidateConsumed[tokenId] = true;
        delete _candidateIndexPlusOne[tokenId];

        if (candidateIndex != lastIndex) {
            _candidateValueByIndex[candidateIndex] = lastTokenId;
            _candidateIndexPlusOne[lastTokenId] = candidateIndex + 1;
        }

        delete _candidateValueByIndex[lastIndex];
        candidatePoolRemaining = lastIndex;
    }

    function _candidateTokenAt(
        uint256 candidateIndex
    ) internal view returns (uint256 tokenId) {
        uint256 storedTokenId = _candidateValueByIndex[candidateIndex];
        return
            storedTokenId == 0
                ? candidateIndex + TOKEN_ID_START
                : storedTokenId;
    }

    /// @dev Unbiased deterministic range reduction for a uniform 256-bit word.
    ///      Rehashing is only the range-reduction retry path; it is not a
    ///      production entropy source.
    function _uniformIndex(
        uint256 entropyWord,
        uint256 upperBound
    ) internal pure returns (uint256) {
        if (upperBound == 0) {
            revert CandidateIndexOutOfRange(0, 0);
        }

        uint256 limit =
            type(uint256).max -
            (type(uint256).max % upperBound);

        uint256 value = entropyWord;
        uint256 retry = 0;

        while (value >= limit) {
            value = uint256(
                keccak256(
                    abi.encode(value, upperBound, retry)
                )
            );
            ++retry;
        }

        return value % upperBound;
    }

    function _assertOpenCandidateAccounting() internal view {
        if (
            candidatePoolRemaining !=
            nonTailIssuanceRemaining + tailReserveCount
        ) {
            revert CandidateAccountingInvariant(
                candidatePoolRemaining,
                nonTailIssuanceRemaining,
                tailReserveCount
            );
        }
    }

    function _assertPrimarySupplyAvailable() internal view {
        if (totalPrimaryIssued >= maxSupply) {
            revert PrimarySupplyInvariant(
                totalPrimaryIssued,
                maxSupply
            );
        }
    }

    /// @dev Internal enforcement bridge only. HellboxBirthPolicy permanently
    ///      rejects every caller except this publication, and a revert here
    ///      reverts the surrounding issuance transaction atomically.
    function _assignBirthIdentity(
        uint256 tokenId,
        uint256 entropyWord
    ) internal returns (bytes32 markCode, bytes32 defectCode) {
        return
            HellboxBirthPolicy(birthPolicy).assignBirthIdentity(
                tokenId,
                entropyWord
            );
    }

    /// @dev While immediate creator copies are pending they have already been
    ///      removed from candidate eligibility but have not yet consumed birth
    ///      inventory. Afterwards every remaining enabled-axis inventory total
    ///      must equal the actual candidate pool exactly.
    function _assertBirthInventoryAccounting() internal view {
        HellboxBirthPolicy policy = HellboxBirthPolicy(birthPolicy);
        uint256 pendingImmediate =
            immediateCreatorCount - immediateCreatorIssued;
        uint256 expectedRemaining =
            candidatePoolRemaining + pendingImmediate;

        if (policy.pressMarkEnabled()) {
            uint256 markRemainingTotal =
                policy.markInventoryRemainingTotal();
            if (markRemainingTotal != expectedRemaining) {
                revert BirthInventoryAccountingInvariant(
                    PRESS_MARK_AXIS_ID,
                    markRemainingTotal,
                    expectedRemaining
                );
            }
        }

        if (policy.pressDefectEnabled()) {
            uint256 defectRemainingTotal =
                policy.defectInventoryRemainingTotal();
            if (defectRemainingTotal != expectedRemaining) {
                revert BirthInventoryAccountingInvariant(
                    PRESS_DEFECT_AXIS_ID,
                    defectRemainingTotal,
                    expectedRemaining
                );
            }
        }
    }

    function _requireIssuanceStateInitialized() internal view {
        if (!issuanceStateInitialized) {
            revert IssuanceStateNotInitialized();
        }
    }

    function _validateCopyId(uint256 tokenId) internal view {
        if (tokenId < TOKEN_ID_START || tokenId > maxSupply) {
            revert InvalidCopyId(tokenId);
        }
    }

    // ---------------------------------------------------------------------
    // Internal commitment / enforcement-preimage encoding
    // ---------------------------------------------------------------------

    /// @dev Canonical Gate 4 fixed-copy enforcement preimage:
    ///      keccak256(abi.encode(domain, typedPolicy)).
    function _computeFixedCopyRulesDigest(
        FixedCopyRulesEnforcement memory policy
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    FIXED_COPY_RULES_ENFORCEMENT_DOMAIN,
                    policy
                )
            );
    }

    /// @dev Canonical Gate 4 birth-trait enforcement preimage:
    ///      keccak256(abi.encode(domain, typedPolicy)).
    function _computeBirthTraitsDigest(
        BirthTraitsEnforcement memory policy
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    BIRTH_TRAITS_ENFORCEMENT_DOMAIN,
                    policy
                )
            );
    }

    /// @dev Canonical Gate 4 deterministic randomization-policy preimage:
    ///      keccak256(abi.encode(domain, typedPolicy)).
    function _computeRandomizationPolicyDigest(
        RandomizationPolicyEnforcement memory policy
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    RANDOMIZATION_POLICY_ENFORCEMENT_DOMAIN,
                    policy
                )
            );
    }

    /// @dev Verifies only the already-bound commitment identity. This function
    ///      deliberately does not activate issuance or create a post-deployment
    ///      configuration path. Deployment-time transport/activation is the next
    ///      coordinated factory/publication step.
    function _verifyEnforcementPolicyDigests(
        FixedCopyRulesEnforcement memory fixedCopyPolicy,
        BirthTraitsEnforcement memory birthTraitsPolicy,
        RandomizationPolicyEnforcement memory randomizationPolicy
    ) internal view {
        bytes32 computedFixedCopyRulesDigest =
            _computeFixedCopyRulesDigest(fixedCopyPolicy);
        if (computedFixedCopyRulesDigest != fixedCopyRulesDigest) {
            revert FixedCopyRulesDigestMismatch(
                fixedCopyRulesDigest,
                computedFixedCopyRulesDigest
            );
        }

        bytes32 computedBirthTraitsDigest =
            _computeBirthTraitsDigest(birthTraitsPolicy);
        if (computedBirthTraitsDigest != birthTraitsDigest) {
            revert BirthTraitsDigestMismatch(
                birthTraitsDigest,
                computedBirthTraitsDigest
            );
        }

        bytes32 computedRandomizationPolicyDigest =
            _computeRandomizationPolicyDigest(randomizationPolicy);
        if (
            computedRandomizationPolicyDigest !=
            randomizationPolicyDigest
        ) {
            revert RandomizationPolicyDigestMismatch(
                randomizationPolicyDigest,
                computedRandomizationPolicyDigest
            );
        }
    }

    function _computeReleaseConfigDigest(
        uint256 chainId,
        address factoryAddress,
        ReleaseConfig memory config,
        CommitmentSet memory commitments
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    RELEASE_CONFIG_DOMAIN,
                    COMMITMENT_SCHEME_VERSION,
                    CONFIG_SCHEMA_VERSION,
                    PUBLICATION_VERSION,
                    TEMPLATE_ID,
                    chainId,
                    factoryAddress,
                    config,
                    commitments
                )
            );
    }

    // ---------------------------------------------------------------------
    // Constructor validation
    // ---------------------------------------------------------------------

    function _validateReleaseConfig(
        ReleaseConfig memory config,
        CommitmentSet memory commitments
    ) internal pure {
        _validatePublicationKey(config.publicationKey);
        _validateCollectionName(config.collectionName);
        _validateCollectionSymbol(config.collectionSymbol);

        if (config.maxSupply == 0) {
            revert InvalidMaxSupply();
        }

        if (
            config.primaryLifetimeCap == 0 ||
            config.primaryLifetimeCap > config.maxSupply
        ) {
            revert InvalidPrimaryLifetimeCap(
                config.primaryLifetimeCap,
                config.maxSupply
            );
        }

        if (
            config.maxPerTransaction == 0 ||
            config.maxPerTransaction > config.primaryLifetimeCap
        ) {
            revert InvalidMaxPerTransaction(
                config.maxPerTransaction,
                config.primaryLifetimeCap
            );
        }

        if (
            config.immediateCreatorCount > config.maxSupply ||
            config.tailReserveCount > config.maxSupply ||
            config.immediateCreatorCount + config.tailReserveCount >
            config.maxSupply
        ) {
            revert InvalidCreatorAllocation(
                config.immediateCreatorCount,
                config.tailReserveCount,
                config.maxSupply
            );
        }

        if (
            (config.immediateCreatorCount > 0 &&
                config.immediateCreatorRecipient == address(0)) ||
            (config.immediateCreatorCount == 0 &&
                config.immediateCreatorRecipient != address(0))
        ) {
            revert InvalidImmediateCreatorRecipient();
        }

        if (
            (config.tailReserveCount > 0 &&
                config.tailRecipient == address(0)) ||
            (config.tailReserveCount == 0 &&
                config.tailRecipient != address(0))
        ) {
            revert InvalidTailRecipient();
        }

        if (
            config.royaltyBps > 10_000 ||
            (config.royaltyBps > 0 &&
                config.royaltyReceiver == address(0)) ||
            (config.royaltyBps == 0 &&
                config.royaltyReceiver != address(0))
        ) {
            revert InvalidRoyaltyConfiguration(
                config.royaltyReceiver,
                config.royaltyBps
            );
        }

        if (config.publisherAuthority == address(0)) {
            revert InvalidPublisherAuthority();
        }

        if (
            (config.archiveCompatible && !config.sealEnabled) ||
            (config.rewardsCompatible && !config.archiveCompatible) ||
            (config.contextualTraitsEnabled &&
                !config.dynamicMetadataEnabled)
        ) {
            revert InvalidCapabilityConfiguration();
        }

        if (
            commitments.publicationManifestDigest == bytes32(0) ||
            commitments.packageDigest == bytes32(0)
        ) {
            revert MissingRequiredCommitment();
        }
    }

    function _validatePublicationKey(string memory value) internal pure {
        bytes memory key = bytes(value);
        uint256 length = key.length;

        if (length == 0 || length > 64) {
            revert InvalidPublicationKey();
        }

        bool previousWasHyphen;

        for (uint256 i = 0; i < length; ++i) {
            uint8 character = uint8(key[i]);
            bool isAlphaNumeric = _isLowerAlphaNumeric(character);
            bool isHyphen = character == 0x2d;

            if (!isAlphaNumeric && !isHyphen) {
                revert InvalidPublicationKey();
            }

            if (isHyphen) {
                if (
                    i == 0 ||
                    i == length - 1 ||
                    previousWasHyphen
                ) {
                    revert InvalidPublicationKey();
                }
                previousWasHyphen = true;
            } else {
                previousWasHyphen = false;
            }
        }
    }

    function _validateCollectionName(string memory value) internal pure {
        uint256 length = bytes(value).length;

        if (length == 0 || length > 128) {
            revert InvalidCollectionNameLength(length);
        }
    }

    function _validateCollectionSymbol(string memory value) internal pure {
        bytes memory symbolBytes = bytes(value);
        uint256 length = symbolBytes.length;

        if (length == 0 || length > 16) {
            revert InvalidCollectionSymbol();
        }

        for (uint256 i = 0; i < length; ++i) {
            uint8 character = uint8(symbolBytes[i]);

            // Visible ASCII only: 0x21 (!) through 0x7e (~).
            if (character < 0x21 || character > 0x7e) {
                revert InvalidCollectionSymbol();
            }
        }
    }

    function _isLowerAlphaNumeric(
        uint8 character
    ) internal pure returns (bool) {
        return
            (character >= 0x61 && character <= 0x7a) ||
            (character >= 0x30 && character <= 0x39);
    }
}
