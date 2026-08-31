// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Royalty} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Royalty.sol";

/// @title HellboxPublication
/// @notice Gate 4 V1 publication kernel: constructor-frozen release identity,
///         configuration commitments, ERC-721 ownership baseline, ERC-2981 royalties,
///         and deterministic primary-issuance accounting primitives.
/// @dev This remains an implementation checkpoint, not yet the finished deployable Gate 4 publication.
///      The deterministic candidate pool, immediate-allocation ordering, wallet lifetime accounting,
///      and true-mintout tail boundary are implemented behind internal functions so they can be
///      exercised with deterministic test doubles before a production entropy provider is selected.
///      Public mint phases, pricing/payment enforcement, committed trait-policy preimages, production
///      randomness, early-close authority, metadata rendering, and later protocols remain to be wired.
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
    bytes32 public immutable commitmentsDigest;
    bytes32 public immutable releaseConfigDigest;

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

    error IssuanceStateAlreadyInitialized();
    error IssuanceStateNotInitialized();
    error InvalidImmediateCreatorCopySet(uint256 expected, uint256 actual);
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
        bytes32 expectedReleaseConfigDigest
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
        commitmentsDigest = commitmentsDigest_;
        releaseConfigDigest = computedReleaseConfigDigest;

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

        for (uint256 i = 0; i < immediateCount; ++i) {
            uint256 tokenId = immediateCopyIds[i];
            _validateCopyId(tokenId);

            if (isImmediateCreatorCopy[tokenId]) {
                revert DuplicateImmediateCreatorCopy(tokenId);
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

        emit IssuanceStateInitialized(
            candidatePoolRemaining,
            nonTailIssuanceRemaining,
            immediateCreatorCount,
            tailReserveCount
        );
    }

    /// @dev Issues one previously verified immediate creator copy. The copy ID
    ///      must already have been removed from candidate eligibility during
    ///      issuance bootstrap. Birth-trait assignment will be inserted before
    ///      this mint when the committed trait preimage is wired.
    function _issueImmediateCreatorCopy(uint256 tokenId) internal {
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

        immediateCreatorCopyIssued[tokenId] = true;
        ++immediateCreatorIssued;
        ++totalPrimaryIssued;

        if (immediateCreatorIssued == immediateCreatorCount) {
            immediateCreatorAllocationComplete = true;
        }

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

        walletLifetimePrimaryUsed[primaryAccount] = used + 1;
        --nonTailIssuanceRemaining;
        ++totalPrimaryIssued;

        _assertOpenCandidateAccounting();

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
    function _awardTailAfterTrueMintOut() internal {
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

            ++tailAwardedCount;
            ++totalPrimaryIssued;

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
    // Internal commitment encoding
    // ---------------------------------------------------------------------

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
