// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {MerkleProof} from "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

/// @dev Existing publication reads plus the future narrow collector request.
interface IHellboxPrimarySalePublication {
    function releaseChainId() external view returns (uint256);

    function factory() external view returns (address);

    function releaseConfigDigest() external view returns (bytes32);

    function commitmentsDigest() external view returns (bytes32);

    function maxSupply() external view returns (uint256);

    function primaryLifetimeCap() external view returns (uint256);

    function maxPerTransaction() external view returns (uint256);

    function immediateCreatorCount() external view returns (uint256);

    function tailReserveCount() external view returns (uint256);

    function nonTailIssuanceRemaining() external view returns (uint256);

    function walletLifetimePrimaryUsed(
        address account
    ) external view returns (uint256);

    function primaryIssuanceClosed() external view returns (bool);

    function prizeWalletIssuanceComplete() external view returns (bool);

    function requestCollectorPrimary(
        address primaryAccount,
        address recipient
    ) external returns (uint256 requestId, uint64 round);
}

/// @dev Existing factory provenance getter.
interface IHellboxPrimarySaleFactory {
    function isPublication(address publication) external view returns (bool);
}

/// @title HellboxPrimarySale
/// @notice Immutable phase admission and request-ID payment escrow for one
///         official Hellbox publication.
/// @dev This contract cannot mint, choose copy IDs, provide randomness, alter
///      lifetime use, change supply, close/reopen a publication, mutate phases,
///      reprice, replace an asset, or redirect proceeds. Payment leaves escrow
///      only after the bound publication confirms the matching NFT issuance.
///      For a standard native issue, the first frozen payable phase—not contract
///      deployment—starts the exact 66d 6h 6m 6s primary-mint clock. Collector
///      requests are restricted to direct EOAs because the publication
///      uses ERC-721 receiver checks and immutable FIFO cannot skip a contract
///      recipient that deliberately rejects delivery. Failed request transactions
///      roll back atomically. This checkpoint exposes no accepted-request refund
///      because publication-side cancellation does not yet exist; Gate 4 liveness
///      review remains required before collector acceptance.
contract HellboxPrimarySale is ReentrancyGuard {
    using Address for address payable;
    using SafeERC20 for IERC20;

    uint256 public constant PRIMARY_SALE_VERSION = 1;
    uint256 public constant MAX_PHASES = 32;
    uint256 public constant NATIVE_MINT_DURATION_SECONDS = 5_724_366;
    uint256 public constant ELIGIBILITY_LEAF_SCHEMA_VERSION = 1;

    bytes32 public constant PRIMARY_SALE_ID =
        keccak256("HELLBOX_PRIMARY_SALE_V1");
    bytes32 public constant SALE_CONFIG_DOMAIN =
        keccak256("HELLBOX_PRIMARY_SALE_V1:CONFIG");
    bytes32 public constant PRICING_POLICIES_ENFORCEMENT_DOMAIN =
        keccak256("HELLBOX_ENFORCEMENT_V1:PRICING_POLICIES");
    bytes32 public constant PAYMENT_ROUTES_ENFORCEMENT_DOMAIN =
        keccak256("HELLBOX_ENFORCEMENT_V1:PAYMENT_ROUTES");
    bytes32 public constant MINT_PHASES_ENFORCEMENT_DOMAIN =
        keccak256("HELLBOX_ENFORCEMENT_V1:MINT_PHASES");
    bytes32 public constant ELIGIBILITY_LEAF_DOMAIN =
        keccak256("HELLBOX_PRIMARY_SALE_V1:ELIGIBILITY_LEAF");

    bytes32 public constant RECIPIENT_POLICY_SELF_ONLY =
        keccak256("SELF_ONLY");
    bytes32 public constant COLLECTOR_CALLER_POLICY_DIRECT_EOA =
        keccak256("DIRECT_EOA");
    bytes32 public constant ALLOCATION_MODE_SHARED_POOL =
        keccak256("SHARED_POOL");
    bytes32 public constant ROLLOVER_POLICY_SHARED_REMAINDER =
        keccak256("SHARED_REMAINDER");
    bytes32 public constant TRAIT_POOL_POLICY_GLOBAL_SHARED =
        keccak256("GLOBAL_SHARED");
    bytes32 public constant EXACT_PAYMENT_POLICY =
        keccak256("EXACT_OR_REVERT");
    bytes32 public constant TOKEN_COMPATIBILITY_EXACT_TRANSFER_V1 =
        keccak256("EXACT_TRANSFER_V1");

    enum PricingMode {
        FREE,
        FIXED_NATIVE,
        FIXED_ERC20
    }

    enum RequestState {
        NONE,
        PENDING,
        FULFILLED,
        SETTLED
    }

    /// @notice Compact V1 enforcement record for one collector phase.
    /// @dev Public labels and richer Press data remain in committed manifests.
    struct Phase {
        bytes32 phaseId;
        uint64 startAt;
        uint64 endAt;
        uint256 phaseCap;
        uint256 phaseWalletCap;
        PricingMode pricingMode;
        address token;
        uint256 exactAmount;
        bytes32 merkleRoot;
    }

    /// @notice Exact HELLBOX_ABI_V1 CommitmentSet field order.
    /// @dev The publication stores only this struct's aggregate digest. Supplying
    ///      the preimage here avoids new publication getters or a mutable setup
    ///      window while allowing the sale to verify its three policy roots.
    struct PublicationCommitmentSet {
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

    /// @dev Canonical compact pricing projection committed by one publication.
    struct PricingCommitment {
        bytes32 phaseId;
        PricingMode pricingMode;
        uint256 exactAmount;
    }

    /// @dev Canonical compact payment-route projection.
    struct PaymentRouteCommitment {
        bytes32 phaseId;
        PricingMode pricingMode;
        address token;
        address proceedsReceiver;
        bytes32 exactPaymentPolicy;
        bytes32 tokenCompatibilityPolicy;
    }

    /// @dev Canonical compact phase-admission projection.
    struct MintPhaseCommitment {
        bytes32 phaseId;
        uint256 order;
        uint64 startAt;
        uint64 endAt;
        uint256 phaseCap;
        uint256 phaseWalletCap;
        bytes32 merkleRoot;
        uint256 eligibilityLeafSchemaVersion;
    }

    struct PrimaryRequest {
        bytes32 phaseId;
        address account;
        PricingMode pricingMode;
        address token;
        uint256 amount;
        uint64 randomnessRound;
        uint256 tokenId;
        RequestState state;
    }

    struct PublicationSnapshot {
        address factory;
        uint256 chainId;
        bytes32 releaseConfigDigest;
        bytes32 commitmentsDigest;
        uint256 maxSupply;
        uint256 lifetimeCap;
        uint256 collectorCapacity;
        bool nativeTimedClosureRequired;
    }

    struct NativeMintWindow {
        bool hasPaidPhase;
        uint256 opensAt;
        uint256 deadline;
    }

    struct PolicyDigests {
        bytes32 pricing;
        bytes32 routes;
        bytes32 phases;
    }

    address public immutable publication;
    address public immutable publicationFactory;
    address public immutable proceedsReceiver;

    uint256 public immutable releaseChainId;
    bytes32 public immutable publicationReleaseConfigDigest;
    bytes32 public immutable publicationCommitmentsDigest;
    bytes32 public immutable pricingPoliciesDigest;
    bytes32 public immutable paymentRoutesDigest;
    bytes32 public immutable mintPhasesDigest;
    bytes32 public immutable saleConfigDigest;

    uint256 public immutable maxSupply;
    uint256 public immutable primaryLifetimeCap;
    uint256 public immutable collectorRequestCapacity;
    uint256 public immutable nativeMintOpensAt;
    uint256 public immutable nativeMintDeadline;
    uint256 public immutable phaseCount;
    bool public immutable prizeBootstrapRequired;

    uint256 public totalCollectorRequests;
    uint256 public pendingCollectorRequests;
    uint256 public fulfilledCollectorRequests;
    uint256 public releasedPayments;
    uint256 public escrowedNative;

    mapping(bytes32 phaseId => Phase phase) private _phaseById;
    mapping(bytes32 phaseId => bool configured) public phaseConfigured;
    mapping(uint256 index => bytes32 phaseId) public phaseIdAt;

    mapping(bytes32 phaseId => uint256 requested) public phaseRequestCount;
    mapping(bytes32 phaseId => uint256 pending)
        public phasePendingRequestCount;
    mapping(bytes32 phaseId => uint256 fulfilled)
        public phaseFulfilledRequestCount;
    mapping(bytes32 phaseId => mapping(address account => uint256 requested))
        public phaseWalletRequestCount;
    mapping(bytes32 phaseId => mapping(address account => uint256 pending))
        public phaseWalletPendingRequestCount;
    mapping(bytes32 phaseId => mapping(address account => uint256 fulfilled))
        public phaseWalletFulfilledRequestCount;
    mapping(address account => uint256 pending) public walletPendingRequests;

    mapping(uint256 requestId => PrimaryRequest request) public requestById;
    mapping(uint256 tokenId => uint256 requestId) public requestIdByTokenId;
    mapping(address token => uint256 amount) public escrowedToken;

    error InvalidPublication(address publication);
    error InvalidPublicationFactory(address factory);
    error UnofficialPublication(address publication, address factory);
    error PublicationChainMismatch(uint256 expected, uint256 actual);
    error InvalidPublicationReleaseDigest();
    error InvalidPublicationCommitmentsDigest();
    error PublicationCommitmentsDigestMismatch(
        bytes32 expected,
        bytes32 computed
    );
    error UnsupportedPublicationTransactionShape(uint256 maxPerTransaction);
    error PrizeBootstrapPolicyMismatch(bool expected, bool supplied);
    error InvalidCollectorRequestCapacity();
    error NativePaidPhaseRequired();
    error PaidPhaseStartRequired(bytes32 phaseId);
    error NativeMintStartAlreadyPassed(
        uint256 opensAt,
        uint256 currentTimestamp
    );
    error InvalidProceedsReceiver(address receiver);
    error UnexpectedProceedsReceiver(address receiver);
    error InvalidPhaseCount(uint256 count);
    error InvalidPhaseId();
    error DuplicatePhase(bytes32 phaseId);
    error InvalidPhaseWindow(bytes32 phaseId, uint64 startAt, uint64 endAt);
    error PhaseOutsideNativeWindow(
        bytes32 phaseId,
        uint64 startAt,
        uint64 endAt,
        uint256 nativeDeadline
    );
    error InvalidPhaseCap(bytes32 phaseId, uint256 cap, uint256 capacity);
    error InvalidPhaseWalletCap(
        bytes32 phaseId,
        uint256 walletCap,
        uint256 lifetimeCap
    );
    error InvalidPhasePayment(
        bytes32 phaseId,
        PricingMode pricingMode,
        address token,
        uint256 amount
    );
    error PricingPoliciesDigestMismatch(bytes32 expected, bytes32 computed);
    error PaymentRoutesDigestMismatch(bytes32 expected, bytes32 computed);
    error MintPhasesDigestMismatch(bytes32 expected, bytes32 computed);

    error DirectEoaRequired(address caller, address transactionOrigin);
    error UnknownPhase(bytes32 phaseId);
    error PrizeWalletBootstrapIncomplete();
    error PublicationIssuanceClosed();
    error NativeMintWindowClosed(uint256 currentTimestamp, uint256 deadline);
    error PhaseInactive(bytes32 phaseId, uint256 currentTimestamp);
    error UnexpectedEligibilityProof(bytes32 phaseId);
    error InvalidEligibilityProof(bytes32 phaseId, address account);
    error CollectorCapacityExhausted(uint256 requested, uint256 capacity);
    error PublicationCapacityReserved(uint256 pending, uint256 remaining);
    error PhaseCapExceeded(bytes32 phaseId, uint256 requested, uint256 cap);
    error PhaseWalletCapExceeded(
        bytes32 phaseId,
        address account,
        uint256 requested,
        uint256 cap
    );
    error LifetimeCapExceeded(
        address account,
        uint256 issued,
        uint256 pending,
        uint256 cap
    );
    error UnexpectedNativeValue(uint256 supplied);
    error IncorrectNativePayment(uint256 required, uint256 supplied);
    error ERC20ReceiptMismatch(
        address token,
        uint256 required,
        uint256 received
    );
    error InvalidPublicationRequest(uint256 requestId, uint64 round);
    error DuplicatePublicationRequest(uint256 requestId);

    error UnauthorizedPublicationCallback(address caller);
    error UnknownPublicationRequest(uint256 requestId);
    error PublicationRequestAlreadyFulfilled(uint256 requestId);
    error PublicationCallbackMismatch(
        uint256 requestId,
        address expectedAccount,
        address suppliedAccount,
        address suppliedRecipient
    );
    error InvalidIssuedTokenId(uint256 requestId, uint256 tokenId);
    error DuplicateIssuedTokenId(uint256 tokenId, uint256 existingRequestId);

    error RequestNotFulfilled(uint256 requestId);
    error PaymentAlreadyReleased(uint256 requestId);
    error RequestHasNoEscrow(uint256 requestId);
    error ERC20ReleaseMismatch(
        address token,
        uint256 required,
        uint256 senderDecrease,
        uint256 receiverIncrease
    );
    error DirectPaymentNotAccepted();

    event PrimarySaleConfigured(
        address indexed publication,
        address indexed proceedsReceiver,
        bytes32 indexed saleConfigDigest,
        uint256 phaseCount,
        uint256 collectorRequestCapacity,
        bool prizeBootstrapRequired
    );

    event CollectorPrimaryRequested(
        uint256 indexed requestId,
        bytes32 indexed phaseId,
        address indexed account,
        PricingMode pricingMode,
        address token,
        uint256 amount,
        uint64 randomnessRound
    );

    event CollectorPrimaryFulfilled(
        uint256 indexed requestId,
        bytes32 indexed phaseId,
        address indexed account,
        uint256 tokenId
    );

    event EscrowReleased(
        uint256 indexed requestId,
        address indexed asset,
        address indexed proceedsReceiver,
        uint256 amount
    );

    constructor(
        address publication_,
        address proceedsReceiver_,
        bool prizeBootstrapRequired_,
        PublicationCommitmentSet memory commitments,
        Phase[] memory phases
    ) {
        PublicationSnapshot memory snapshot = _readPublication(
            publication_,
            prizeBootstrapRequired_
        );

        uint256 count = phases.length;
        if (count == 0 || count > MAX_PHASES) {
            revert InvalidPhaseCount(count);
        }

        NativeMintWindow memory mintWindow = _deriveNativeMintWindow(
            phases,
            snapshot.nativeTimedClosureRequired
        );

        _validateProceedsReceiver(
            proceedsReceiver_,
            mintWindow.hasPaidPhase,
            publication_,
            snapshot.factory
        );

        PolicyDigests memory policyDigests = _loadAndDigestPhases(
            phases,
            proceedsReceiver_,
            prizeBootstrapRequired_,
            snapshot.lifetimeCap,
            snapshot.collectorCapacity,
            mintWindow.deadline
        );

        _validateCommitmentBinding(
            snapshot.commitmentsDigest,
            commitments,
            policyDigests
        );

        publication = publication_;
        publicationFactory = snapshot.factory;
        proceedsReceiver = proceedsReceiver_;
        releaseChainId = snapshot.chainId;
        publicationReleaseConfigDigest = snapshot.releaseConfigDigest;
        publicationCommitmentsDigest = snapshot.commitmentsDigest;
        pricingPoliciesDigest = policyDigests.pricing;
        paymentRoutesDigest = policyDigests.routes;
        mintPhasesDigest = policyDigests.phases;
        maxSupply = snapshot.maxSupply;
        primaryLifetimeCap = snapshot.lifetimeCap;
        collectorRequestCapacity = snapshot.collectorCapacity;
        nativeMintOpensAt = mintWindow.opensAt;
        nativeMintDeadline = mintWindow.deadline;
        phaseCount = count;
        prizeBootstrapRequired = prizeBootstrapRequired_;

        bytes32 configDigest = keccak256(
            abi.encode(
                SALE_CONFIG_DOMAIN,
                PRIMARY_SALE_VERSION,
                snapshot.chainId,
                snapshot.factory,
                publication_,
                snapshot.releaseConfigDigest,
                snapshot.commitmentsDigest,
                proceedsReceiver_,
                prizeBootstrapRequired_,
                phases,
                policyDigests
            )
        );
        saleConfigDigest = configDigest;

        emit PrimarySaleConfigured(
            publication_,
            proceedsReceiver_,
            configDigest,
            count,
            snapshot.collectorCapacity,
            prizeBootstrapRequired_
        );
    }

    function phaseById(
        bytes32 phaseId
    ) external view returns (Phase memory phase) {
        if (!phaseConfigured[phaseId]) {
            revert UnknownPhase(phaseId);
        }
        return _phaseById[phaseId];
    }

    /// @notice Standard double-hashed Merkle leaf for one wallet/phase.
    function eligibilityLeaf(
        bytes32 phaseId,
        address account
    ) public view returns (bytes32) {
        bytes32 inner = keccak256(
            abi.encode(
                ELIGIBILITY_LEAF_DOMAIN,
                releaseChainId,
                publicationFactory,
                publicationReleaseConfigDigest,
                phaseId,
                account
            )
        );
        return keccak256(bytes.concat(inner));
    }

    /// @notice Requests exactly one randomized self-recipient primary copy.
    function requestPrimary(
        bytes32 phaseId,
        bytes32[] calldata merkleProof
    ) external payable nonReentrant returns (uint256 requestId, uint64 round) {
        address account = msg.sender;
        if (account != tx.origin || account.code.length != 0) {
            revert DirectEoaRequired(account, tx.origin);
        }
        if (!phaseConfigured[phaseId]) {
            revert UnknownPhase(phaseId);
        }

        Phase storage phase = _phaseById[phaseId];

        _validateAndReserveRequest(
            phaseId,
            phase,
            account,
            merkleProof
        );
        _collectPayment(phase, account);

        (requestId, round) =
            IHellboxPrimarySalePublication(publication)
                .requestCollectorPrimary(account, account);

        _recordPublicationRequest(
            requestId,
            round,
            phaseId,
            phase,
            account
        );
    }

    /// @notice Publication-only completion callback. No value leaves here.
    function onCollectorPrimaryFulfilled(
        uint256 requestId,
        address primaryAccount,
        address recipient,
        uint256 tokenId
    ) external nonReentrant {
        if (msg.sender != publication) {
            revert UnauthorizedPublicationCallback(msg.sender);
        }

        PrimaryRequest storage request = requestById[requestId];
        if (request.state == RequestState.NONE) {
            revert UnknownPublicationRequest(requestId);
        }
        if (request.state != RequestState.PENDING) {
            revert PublicationRequestAlreadyFulfilled(requestId);
        }

        address account = request.account;
        if (primaryAccount != account || recipient != account) {
            revert PublicationCallbackMismatch(
                requestId,
                account,
                primaryAccount,
                recipient
            );
        }
        if (tokenId == 0 || tokenId > maxSupply) {
            revert InvalidIssuedTokenId(requestId, tokenId);
        }

        uint256 existingRequestId = requestIdByTokenId[tokenId];
        if (existingRequestId != 0) {
            revert DuplicateIssuedTokenId(tokenId, existingRequestId);
        }

        request.tokenId = tokenId;
        request.state = request.amount == 0
            ? RequestState.SETTLED
            : RequestState.FULFILLED;
        requestIdByTokenId[tokenId] = requestId;

        pendingCollectorRequests -= 1;
        phasePendingRequestCount[request.phaseId] -= 1;
        phaseWalletPendingRequestCount[request.phaseId][account] -= 1;
        walletPendingRequests[account] -= 1;
        fulfilledCollectorRequests += 1;
        phaseFulfilledRequestCount[request.phaseId] += 1;
        phaseWalletFulfilledRequestCount[request.phaseId][account] += 1;

        emit CollectorPrimaryFulfilled(
            requestId,
            request.phaseId,
            account,
            tokenId
        );
    }

    /// @notice Permissionlessly releases one fulfilled paid escrow.
    function releasePayment(uint256 requestId) external nonReentrant {
        PrimaryRequest storage request = requestById[requestId];
        RequestState state = request.state;
        if (state == RequestState.NONE) {
            revert UnknownPublicationRequest(requestId);
        }
        if (state == RequestState.PENDING) {
            revert RequestNotFulfilled(requestId);
        }

        uint256 amount = request.amount;
        if (amount == 0) {
            revert RequestHasNoEscrow(requestId);
        }
        if (state == RequestState.SETTLED) {
            revert PaymentAlreadyReleased(requestId);
        }

        request.state = RequestState.SETTLED;
        releasedPayments += 1;

        address asset = request.token;
        if (request.pricingMode == PricingMode.FIXED_NATIVE) {
            escrowedNative -= amount;
            payable(proceedsReceiver).sendValue(amount);
        } else {
            escrowedToken[asset] -= amount;
            _releaseExactErc20(IERC20(asset), amount);
        }

        emit EscrowReleased(
            requestId,
            asset,
            proceedsReceiver,
            amount
        );
    }

    receive() external payable {
        revert DirectPaymentNotAccepted();
    }

    function _readPublication(
        address publication_,
        bool prizeBootstrapRequired_
    ) private view returns (PublicationSnapshot memory snapshot) {
        if (publication_ == address(0) || publication_.code.length == 0) {
            revert InvalidPublication(publication_);
        }

        IHellboxPrimarySalePublication publicationContract =
            IHellboxPrimarySalePublication(publication_);

        snapshot.chainId = publicationContract.releaseChainId();
        if (snapshot.chainId != block.chainid) {
            revert PublicationChainMismatch(snapshot.chainId, block.chainid);
        }

        snapshot.factory = publicationContract.factory();
        if (
            snapshot.factory == address(0) ||
            snapshot.factory.code.length == 0
        ) {
            revert InvalidPublicationFactory(snapshot.factory);
        }
        if (
            !IHellboxPrimarySaleFactory(snapshot.factory).isPublication(
                publication_
            )
        ) {
            revert UnofficialPublication(publication_, snapshot.factory);
        }

        snapshot.releaseConfigDigest =
            publicationContract.releaseConfigDigest();
        if (snapshot.releaseConfigDigest == bytes32(0)) {
            revert InvalidPublicationReleaseDigest();
        }

        snapshot.commitmentsDigest = publicationContract.commitmentsDigest();
        if (snapshot.commitmentsDigest == bytes32(0)) {
            revert InvalidPublicationCommitmentsDigest();
        }

        uint256 transactionLimit = publicationContract.maxPerTransaction();
        if (transactionLimit != 1) {
            revert UnsupportedPublicationTransactionShape(transactionLimit);
        }

        uint256 immediateCount =
            publicationContract.immediateCreatorCount();
        bool expectedPrizeBootstrap = immediateCount != 0;
        if (prizeBootstrapRequired_ != expectedPrizeBootstrap) {
            revert PrizeBootstrapPolicyMismatch(
                expectedPrizeBootstrap,
                prizeBootstrapRequired_
            );
        }

        snapshot.lifetimeCap = publicationContract.primaryLifetimeCap();
        snapshot.maxSupply = publicationContract.maxSupply();
        uint256 tailCount = publicationContract.tailReserveCount();
        uint256 reservedSupply =
            immediateCount +
            tailCount +
            (prizeBootstrapRequired_ ? 1 : 0);
        if (
            snapshot.maxSupply <= reservedSupply ||
            snapshot.lifetimeCap == 0
        ) {
            revert InvalidCollectorRequestCapacity();
        }
        snapshot.collectorCapacity = snapshot.maxSupply - reservedSupply;
        snapshot.nativeTimedClosureRequired =
            snapshot.maxSupply == 216 &&
            snapshot.lifetimeCap == 6 &&
            transactionLimit == 1 &&
            immediateCount == 6 &&
            tailCount == 3;
    }

    /// @dev For the standard native profile, the first frozen payable phase is
    ///      the paid mint opening and starts the exact 66d 6h 6m 6s clock.
    ///      Publication deployment time is deliberately irrelevant. Free proving
    ///      profiles such as SciVive remain outside this native timer.
    function _deriveNativeMintWindow(
        Phase[] memory phases,
        bool nativeTimedClosureRequired
    ) private view returns (NativeMintWindow memory window) {
        uint256 count = phases.length;
        for (uint256 i = 0; i < count; ++i) {
            Phase memory phase = phases[i];
            if (phase.pricingMode == PricingMode.FREE) {
                continue;
            }

            window.hasPaidPhase = true;
            if (!nativeTimedClosureRequired) {
                continue;
            }
            if (phase.startAt == 0) {
                revert PaidPhaseStartRequired(phase.phaseId);
            }
            if (window.opensAt == 0 || phase.startAt < window.opensAt) {
                window.opensAt = phase.startAt;
            }
        }

        if (!nativeTimedClosureRequired) {
            return window;
        }
        if (!window.hasPaidPhase) {
            revert NativePaidPhaseRequired();
        }
        if (window.opensAt < block.timestamp) {
            revert NativeMintStartAlreadyPassed(
                window.opensAt,
                block.timestamp
            );
        }

        window.deadline =
            window.opensAt + NATIVE_MINT_DURATION_SECONDS;
    }

    function _validateProceedsReceiver(
        address receiver,
        bool hasPaidPhase,
        address publication_,
        address factory_
    ) private view {
        if (!hasPaidPhase) {
            if (receiver != address(0)) {
                revert UnexpectedProceedsReceiver(receiver);
            }
            return;
        }

        if (
            receiver == address(0) ||
            receiver == address(this) ||
            receiver == publication_ ||
            receiver == factory_ ||
            receiver.code.length == 0
        ) {
            revert InvalidProceedsReceiver(receiver);
        }
    }

    function _loadAndDigestPhases(
        Phase[] memory phases,
        address receiver,
        bool prizeBootstrapRequired_,
        uint256 lifetimeCap,
        uint256 collectorCapacity,
        uint256 deadline
    ) private returns (PolicyDigests memory digests) {
        uint256 count = phases.length;
        PricingCommitment[] memory pricing =
            new PricingCommitment[](count);
        PaymentRouteCommitment[] memory routes =
            new PaymentRouteCommitment[](count);
        MintPhaseCommitment[] memory mintPhases =
            new MintPhaseCommitment[](count);

        for (uint256 i = 0; i < count; ++i) {
            Phase memory phase = phases[i];
            _validatePhase(
                phase,
                lifetimeCap,
                collectorCapacity,
                deadline
            );
            if (phaseConfigured[phase.phaseId]) {
                revert DuplicatePhase(phase.phaseId);
            }

            phaseConfigured[phase.phaseId] = true;
            _phaseById[phase.phaseId] = phase;
            phaseIdAt[i] = phase.phaseId;

            pricing[i] = PricingCommitment({
                phaseId: phase.phaseId,
                pricingMode: phase.pricingMode,
                exactAmount: phase.exactAmount
            });

            routes[i] = PaymentRouteCommitment({
                phaseId: phase.phaseId,
                pricingMode: phase.pricingMode,
                token: phase.token,
                proceedsReceiver: phase.pricingMode == PricingMode.FREE
                    ? address(0)
                    : receiver,
                exactPaymentPolicy: phase.pricingMode == PricingMode.FREE
                    ? bytes32(0)
                    : EXACT_PAYMENT_POLICY,
                tokenCompatibilityPolicy:
                    phase.pricingMode == PricingMode.FIXED_ERC20
                    ? TOKEN_COMPATIBILITY_EXACT_TRANSFER_V1
                    : bytes32(0)
            });

            mintPhases[i] = MintPhaseCommitment({
                phaseId: phase.phaseId,
                order: i,
                startAt: phase.startAt,
                endAt: phase.endAt,
                phaseCap: phase.phaseCap,
                phaseWalletCap: phase.phaseWalletCap,
                merkleRoot: phase.merkleRoot,
                eligibilityLeafSchemaVersion:
                    phase.merkleRoot == bytes32(0)
                    ? 0
                    : ELIGIBILITY_LEAF_SCHEMA_VERSION
            });
        }

        digests.pricing = keccak256(
            abi.encode(PRICING_POLICIES_ENFORCEMENT_DOMAIN, pricing)
        );
        digests.routes = keccak256(
            abi.encode(PAYMENT_ROUTES_ENFORCEMENT_DOMAIN, routes)
        );
        digests.phases = keccak256(
            abi.encode(
                MINT_PHASES_ENFORCEMENT_DOMAIN,
                prizeBootstrapRequired_,
                RECIPIENT_POLICY_SELF_ONLY,
                COLLECTOR_CALLER_POLICY_DIRECT_EOA,
                ALLOCATION_MODE_SHARED_POOL,
                ROLLOVER_POLICY_SHARED_REMAINDER,
                TRAIT_POOL_POLICY_GLOBAL_SHARED,
                mintPhases
            )
        );
    }

    function _validateCommitmentBinding(
        bytes32 expectedAggregate,
        PublicationCommitmentSet memory commitments,
        PolicyDigests memory policyDigests
    ) private pure {
        bytes32 computedAggregate = keccak256(abi.encode(commitments));
        if (computedAggregate != expectedAggregate) {
            revert PublicationCommitmentsDigestMismatch(
                expectedAggregate,
                computedAggregate
            );
        }
        if (commitments.pricingPoliciesDigest != policyDigests.pricing) {
            revert PricingPoliciesDigestMismatch(
                commitments.pricingPoliciesDigest,
                policyDigests.pricing
            );
        }
        if (commitments.paymentRoutesDigest != policyDigests.routes) {
            revert PaymentRoutesDigestMismatch(
                commitments.paymentRoutesDigest,
                policyDigests.routes
            );
        }
        if (commitments.mintPhasesDigest != policyDigests.phases) {
            revert MintPhasesDigestMismatch(
                commitments.mintPhasesDigest,
                policyDigests.phases
            );
        }
    }

    function _validateAndReserveRequest(
        bytes32 phaseId,
        Phase storage phase,
        address account,
        bytes32[] calldata merkleProof
    ) private {
        IHellboxPrimarySalePublication publicationContract =
            IHellboxPrimarySalePublication(publication);

        _requirePublicationOpen(publicationContract);
        _requirePhaseActive(phaseId, phase);
        _requireEligible(
            phaseId,
            phase.merkleRoot,
            account,
            merkleProof
        );
        _reserveRequest(
            phaseId,
            phase,
            account,
            publicationContract
        );
    }

    function _reserveRequest(
        bytes32 phaseId,
        Phase storage phase,
        address account,
        IHellboxPrimarySalePublication publicationContract
    ) private {
        uint256 requested = totalCollectorRequests;
        if (requested >= collectorRequestCapacity) {
            revert CollectorCapacityExhausted(
                requested,
                collectorRequestCapacity
            );
        }

        uint256 pending = pendingCollectorRequests;
        uint256 remaining = publicationContract.nonTailIssuanceRemaining();
        if (pending >= remaining) {
            revert PublicationCapacityReserved(pending, remaining);
        }

        uint256 phaseRequested = phaseRequestCount[phaseId];
        if (phaseRequested >= phase.phaseCap) {
            revert PhaseCapExceeded(
                phaseId,
                phaseRequested,
                phase.phaseCap
            );
        }

        uint256 phaseWalletRequested =
            phaseWalletRequestCount[phaseId][account];
        if (phaseWalletRequested >= phase.phaseWalletCap) {
            revert PhaseWalletCapExceeded(
                phaseId,
                account,
                phaseWalletRequested,
                phase.phaseWalletCap
            );
        }

        uint256 issued =
            publicationContract.walletLifetimePrimaryUsed(account);
        uint256 walletPending = walletPendingRequests[account];
        if (issued + walletPending >= primaryLifetimeCap) {
            revert LifetimeCapExceeded(
                account,
                issued,
                walletPending,
                primaryLifetimeCap
            );
        }

        totalCollectorRequests = requested + 1;
        pendingCollectorRequests = pending + 1;
        phaseRequestCount[phaseId] = phaseRequested + 1;
        phasePendingRequestCount[phaseId] += 1;
        phaseWalletRequestCount[phaseId][account] =
            phaseWalletRequested + 1;
        phaseWalletPendingRequestCount[phaseId][account] += 1;
        walletPendingRequests[account] = walletPending + 1;
    }

    function _recordPublicationRequest(
        uint256 requestId,
        uint64 round,
        bytes32 phaseId,
        Phase storage phase,
        address account
    ) private {
        if (requestId == 0 || round == 0) {
            revert InvalidPublicationRequest(requestId, round);
        }
        if (requestById[requestId].state != RequestState.NONE) {
            revert DuplicatePublicationRequest(requestId);
        }

        requestById[requestId] = PrimaryRequest({
            phaseId: phaseId,
            account: account,
            pricingMode: phase.pricingMode,
            token: phase.token,
            amount: phase.exactAmount,
            randomnessRound: round,
            tokenId: 0,
            state: RequestState.PENDING
        });

        emit CollectorPrimaryRequested(
            requestId,
            phaseId,
            account,
            phase.pricingMode,
            phase.token,
            phase.exactAmount,
            round
        );
    }

    function _requirePublicationOpen(
        IHellboxPrimarySalePublication publicationContract
    ) private view {
        if (publicationContract.primaryIssuanceClosed()) {
            revert PublicationIssuanceClosed();
        }
        if (
            prizeBootstrapRequired &&
            !publicationContract.prizeWalletIssuanceComplete()
        ) {
            revert PrizeWalletBootstrapIncomplete();
        }

        uint256 deadline = nativeMintDeadline;
        if (deadline != 0 && block.timestamp >= deadline) {
            revert NativeMintWindowClosed(block.timestamp, deadline);
        }
    }

    function _requirePhaseActive(
        bytes32 phaseId,
        Phase storage phase
    ) private view {
        uint256 currentTimestamp = block.timestamp;
        if (
            (phase.startAt != 0 && currentTimestamp < phase.startAt) ||
            (phase.endAt != 0 && currentTimestamp >= phase.endAt)
        ) {
            revert PhaseInactive(phaseId, currentTimestamp);
        }
    }

    function _requireEligible(
        bytes32 phaseId,
        bytes32 root,
        address account,
        bytes32[] calldata proof
    ) private view {
        if (root == bytes32(0)) {
            if (proof.length != 0) {
                revert UnexpectedEligibilityProof(phaseId);
            }
            return;
        }

        if (
            !MerkleProof.verifyCalldata(
                proof,
                root,
                eligibilityLeaf(phaseId, account)
            )
        ) {
            revert InvalidEligibilityProof(phaseId, account);
        }
    }

    function _collectPayment(
        Phase storage phase,
        address account
    ) private {
        PricingMode mode = phase.pricingMode;
        uint256 amount = phase.exactAmount;

        if (mode == PricingMode.FREE) {
            if (msg.value != 0) {
                revert UnexpectedNativeValue(msg.value);
            }
            return;
        }

        if (mode == PricingMode.FIXED_NATIVE) {
            if (msg.value != amount) {
                revert IncorrectNativePayment(amount, msg.value);
            }
            escrowedNative += amount;
            return;
        }

        if (msg.value != 0) {
            revert UnexpectedNativeValue(msg.value);
        }

        IERC20 token = IERC20(phase.token);
        uint256 beforeBalance = token.balanceOf(address(this));
        token.safeTransferFrom(account, address(this), amount);
        uint256 afterBalance = token.balanceOf(address(this));
        uint256 received = afterBalance >= beforeBalance
            ? afterBalance - beforeBalance
            : 0;
        if (received != amount) {
            revert ERC20ReceiptMismatch(address(token), amount, received);
        }
        escrowedToken[address(token)] += amount;
    }

    function _releaseExactErc20(IERC20 token, uint256 amount) private {
        uint256 senderBefore = token.balanceOf(address(this));
        uint256 receiverBefore = token.balanceOf(proceedsReceiver);

        token.safeTransfer(proceedsReceiver, amount);

        uint256 senderAfter = token.balanceOf(address(this));
        uint256 receiverAfter = token.balanceOf(proceedsReceiver);
        uint256 senderDecrease = senderBefore >= senderAfter
            ? senderBefore - senderAfter
            : 0;
        uint256 receiverIncrease = receiverAfter >= receiverBefore
            ? receiverAfter - receiverBefore
            : 0;

        if (senderDecrease != amount || receiverIncrease != amount) {
            revert ERC20ReleaseMismatch(
                address(token),
                amount,
                senderDecrease,
                receiverIncrease
            );
        }
    }

    function _validatePhase(
        Phase memory phase,
        uint256 lifetimeCap,
        uint256 collectorCapacity,
        uint256 deadline
    ) private view {
        if (phase.phaseId == bytes32(0)) {
            revert InvalidPhaseId();
        }
        if (phase.endAt != 0 && phase.endAt <= phase.startAt) {
            revert InvalidPhaseWindow(
                phase.phaseId,
                phase.startAt,
                phase.endAt
            );
        }
        if (
            deadline != 0 &&
            (
                phase.startAt >= deadline ||
                (phase.endAt != 0 && phase.endAt > deadline)
            )
        ) {
            revert PhaseOutsideNativeWindow(
                phase.phaseId,
                phase.startAt,
                phase.endAt,
                deadline
            );
        }
        if (
            phase.phaseCap == 0 ||
            phase.phaseCap > collectorCapacity
        ) {
            revert InvalidPhaseCap(
                phase.phaseId,
                phase.phaseCap,
                collectorCapacity
            );
        }
        if (
            phase.phaseWalletCap == 0 ||
            phase.phaseWalletCap > lifetimeCap ||
            phase.phaseWalletCap > phase.phaseCap
        ) {
            revert InvalidPhaseWalletCap(
                phase.phaseId,
                phase.phaseWalletCap,
                lifetimeCap
            );
        }

        bool validPayment;
        if (phase.pricingMode == PricingMode.FREE) {
            validPayment =
                phase.token == address(0) &&
                phase.exactAmount == 0;
        } else if (phase.pricingMode == PricingMode.FIXED_NATIVE) {
            validPayment =
                phase.token == address(0) &&
                phase.exactAmount != 0;
        } else {
            validPayment =
                phase.token != address(0) &&
                phase.token.code.length != 0 &&
                phase.exactAmount != 0;
        }

        if (!validPayment) {
            revert InvalidPhasePayment(
                phase.phaseId,
                phase.pricingMode,
                phase.token,
                phase.exactAmount
            );
        }
    }
}
