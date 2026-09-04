// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxPrimarySale} from "../contracts/HellboxPrimarySale.sol";

interface PrimarySaleVm {
    function deal(address account, uint256 newBalance) external;

    function prank(address msgSender) external;

    function prank(address msgSender, address txOrigin) external;

    function warp(uint256 newTimestamp) external;

    function expectPartialRevert(bytes4 revertData) external;
}

contract PrimarySalePublicationMock {
    struct MockRequest {
        address account;
        address recipient;
        bool fulfilled;
    }

    uint256 public releaseChainId;
    address public factory;
    bytes32 public releaseConfigDigest = keccak256("release-config");
    bytes32 public commitmentsDigest;

    uint256 public maxSupply = 216;
    uint256 public primaryLifetimeCap = 6;
    uint256 public maxPerTransaction = 1;
    uint256 public immediateCreatorCount = 6;
    uint256 public tailReserveCount = 3;
    uint256 public nativeMintDeadline;
    uint256 public nonTailIssuanceRemaining = 206;

    bool public primaryIssuanceClosed;
    bool public prizeWalletIssuanceComplete;
    bool public rejectCollectorRequests;

    address public sale;
    uint256 public requestCount = 7;

    mapping(address publication => bool official) public isPublication;
    mapping(address account => uint256 used) public walletLifetimePrimaryUsed;
    mapping(uint256 requestId => MockRequest request) public mockRequestById;

    error UnauthorizedSale(address caller);
    error CollectorRequestRejected();
    error UnknownMockRequest(uint256 requestId);
    error MockRequestAlreadyFulfilled(uint256 requestId);

    constructor(uint256 deadline) {
        releaseChainId = block.chainid;
        factory = address(this);
        isPublication[address(this)] = true;
        nativeMintDeadline = deadline;
    }

    function configureProfile(
        uint256 supply,
        uint256 lifetimeCap,
        uint256 immediateCount,
        uint256 tailCount,
        uint256 deadline,
        uint256 nonTailRemaining
    ) external {
        maxSupply = supply;
        primaryLifetimeCap = lifetimeCap;
        immediateCreatorCount = immediateCount;
        tailReserveCount = tailCount;
        nativeMintDeadline = deadline;
        nonTailIssuanceRemaining = nonTailRemaining;
    }

    function setSale(address sale_) external {
        sale = sale_;
    }

    function setCommitmentsDigest(bytes32 digest) external {
        commitmentsDigest = digest;
    }

    function setOfficialPublication(bool value) external {
        isPublication[address(this)] = value;
    }

    function setPrizeWalletIssuanceComplete(bool value) external {
        prizeWalletIssuanceComplete = value;
    }

    function setPrimaryIssuanceClosed(bool value) external {
        primaryIssuanceClosed = value;
    }

    function setRejectCollectorRequests(bool value) external {
        rejectCollectorRequests = value;
    }

    function setNonTailIssuanceRemaining(uint256 value) external {
        nonTailIssuanceRemaining = value;
    }

    function setWalletLifetimePrimaryUsed(
        address account,
        uint256 value
    ) external {
        walletLifetimePrimaryUsed[account] = value;
    }

    function setMaxPerTransaction(uint256 value) external {
        maxPerTransaction = value;
    }

    function requestCollectorPrimary(
        address primaryAccount,
        address recipient
    ) external returns (uint256 requestId, uint64 round) {
        if (msg.sender != sale) {
            revert UnauthorizedSale(msg.sender);
        }
        if (rejectCollectorRequests) {
            revert CollectorRequestRejected();
        }

        requestId = ++requestCount;
        round = uint64(10_000 + requestId);
        mockRequestById[requestId] = MockRequest({
            account: primaryAccount,
            recipient: recipient,
            fulfilled: false
        });
    }

    function fulfillCollectorRequest(
        uint256 requestId,
        uint256 tokenId
    ) external {
        MockRequest storage request = mockRequestById[requestId];
        if (request.account == address(0)) {
            revert UnknownMockRequest(requestId);
        }
        if (request.fulfilled) {
            revert MockRequestAlreadyFulfilled(requestId);
        }

        request.fulfilled = true;
        nonTailIssuanceRemaining -= 1;
        walletLifetimePrimaryUsed[request.account] += 1;

        HellboxPrimarySale(payable(sale)).onCollectorPrimaryFulfilled(
            requestId,
            request.account,
            request.recipient,
            tokenId
        );
    }

    function callbackWith(
        uint256 requestId,
        address account,
        address recipient,
        uint256 tokenId
    ) external {
        HellboxPrimarySale(payable(sale)).onCollectorPrimaryFulfilled(
            requestId,
            account,
            recipient,
            tokenId
        );
    }
}

contract PrimarySaleProceedsReceiver {
    bool public acceptsNative = true;

    function setAcceptsNative(bool value) external {
        acceptsNative = value;
    }

    receive() external payable {
        require(acceptsNative, "native rejected");
    }
}

contract PrimarySaleContractCollector {
    function requestFree(
        HellboxPrimarySale sale,
        bytes32 phaseId
    ) external returns (uint256 requestId, uint64 round) {
        bytes32[] memory noProof = new bytes32[](0);
        return sale.requestPrimary(phaseId, noProof);
    }
}

contract PrimarySaleConstructorCollector {
    constructor(HellboxPrimarySale sale, bytes32 phaseId) {
        bytes32[] memory noProof = new bytes32[](0);
        sale.requestPrimary(phaseId, noProof);
    }
}

contract PrimarySaleTokenMock {
    mapping(address account => uint256 amount) public balanceOf;
    mapping(address owner => mapping(address spender => uint256 amount))
        public allowance;

    bool public shortTransferFrom;
    bool public shortTransfer;

    function setShortTransferFrom(bool value) external {
        shortTransferFrom = value;
    }

    function setShortTransfer(bool value) external {
        shortTransfer = value;
    }

    function mint(address account, uint256 amount) external {
        balanceOf[account] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += shortTransfer ? amount - 1 : amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "allowance");
        require(balanceOf[from] >= amount, "balance");
        allowance[from][msg.sender] = allowed - amount;
        balanceOf[from] -= amount;
        balanceOf[to] += shortTransferFrom ? amount - 1 : amount;
        return true;
    }
}

contract HellboxPrimarySaleTest {
    PrimarySaleVm internal constant VM = PrimarySaleVm(
        address(uint160(uint256(keccak256("hevm cheat code"))))
    );

    address internal constant ALICE =
        0xA000000000000000000000000000000000000001;
    address internal constant BOB =
        0xb000000000000000000000000000000000000002;
    address internal constant CAROL =
        0xC000000000000000000000000000000000000003;

    bytes32 internal constant FREE_PHASE = keccak256("FREE_PHASE");
    bytes32 internal constant NATIVE_PHASE = keccak256("NATIVE_PHASE");
    bytes32 internal constant ERC20_PHASE = keccak256("ERC20_PHASE");

    uint256 internal constant START = 1_900_000_000;
    uint256 internal constant NATIVE_PRICE = 2 ether;
    uint256 internal constant TOKEN_PRICE = 250 ether;

    struct StandardDeployment {
        HellboxPrimarySale sale;
        PrimarySalePublicationMock publication;
        PrimarySaleProceedsReceiver receiver;
        PrimarySaleTokenMock token;
    }

    function testConfigurationBindsOfficialPublicationAndCommitments() public {
        StandardDeployment memory deployment = _deployStandard();
        HellboxPrimarySale sale = deployment.sale;

        require(
            sale.publication() == address(deployment.publication),
            "publication"
        );
        require(
            sale.publicationFactory() == address(deployment.publication),
            "factory"
        );
        require(
            sale.proceedsReceiver() == address(deployment.receiver),
            "receiver"
        );
        require(sale.releaseChainId() == block.chainid, "chain");
        require(sale.maxSupply() == 216, "supply");
        require(sale.primaryLifetimeCap() == 6, "lifetime cap");
        require(sale.collectorRequestCapacity() == 206, "capacity");
        require(sale.nativeMintDeadline() == START + 20_000, "deadline");
        require(sale.phaseCount() == 3, "phase count");
        require(sale.prizeBootstrapRequired(), "prize bootstrap");
        require(sale.saleConfigDigest() != bytes32(0), "sale digest");
        require(
            sale.publicationCommitmentsDigest() ==
                deployment.publication.commitmentsDigest(),
            "aggregate"
        );

        HellboxPrimarySale.Phase memory phase = sale.phaseById(NATIVE_PHASE);
        require(phase.exactAmount == NATIVE_PRICE, "native price");
        require(
            phase.pricingMode == HellboxPrimarySale.PricingMode.FIXED_NATIVE,
            "native mode"
        );
    }

    function testWrongPublicationCommitmentPreimageRejectsDeployment() public {
        VM.warp(START);
        PrimarySaleProceedsReceiver receiver = new PrimarySaleProceedsReceiver();
        PrimarySaleTokenMock token = new PrimarySaleTokenMock();
        PrimarySalePublicationMock publication =
            new PrimarySalePublicationMock(START + 20_000);
        HellboxPrimarySale.Phase[] memory phases =
            _standardPhases(address(publication), address(token));
        HellboxPrimarySale.PublicationCommitmentSet memory commitments =
            _commitmentSet(phases, address(receiver), true);

        publication.setCommitmentsDigest(
            bytes32(uint256(keccak256(abi.encode(commitments))) + 1)
        );

        VM.expectPartialRevert(
            HellboxPrimarySale.PublicationCommitmentsDigestMismatch.selector
        );
        new HellboxPrimarySale(
            address(publication),
            address(receiver),
            true,
            commitments,
            phases
        );
    }

    function testWrongPolicyRootRejectsDeployment() public {
        VM.warp(START);
        PrimarySaleProceedsReceiver receiver = new PrimarySaleProceedsReceiver();
        PrimarySaleTokenMock token = new PrimarySaleTokenMock();
        PrimarySalePublicationMock publication =
            new PrimarySalePublicationMock(START + 20_000);
        HellboxPrimarySale.Phase[] memory phases =
            _standardPhases(address(publication), address(token));
        HellboxPrimarySale.PublicationCommitmentSet memory commitments =
            _commitmentSet(phases, address(receiver), true);

        commitments.pricingPoliciesDigest = keccak256("wrong-pricing");
        publication.setCommitmentsDigest(keccak256(abi.encode(commitments)));

        VM.expectPartialRevert(
            HellboxPrimarySale.PricingPoliciesDigestMismatch.selector
        );
        new HellboxPrimarySale(
            address(publication),
            address(receiver),
            true,
            commitments,
            phases
        );
    }

    function testUnofficialAndUnsupportedPublicationShapesReject() public {
        VM.warp(START);
        PrimarySaleProceedsReceiver receiver = new PrimarySaleProceedsReceiver();
        PrimarySaleTokenMock token = new PrimarySaleTokenMock();
        PrimarySalePublicationMock publication =
            new PrimarySalePublicationMock(START + 20_000);
        HellboxPrimarySale.Phase[] memory phases =
            _standardPhases(address(publication), address(token));
        HellboxPrimarySale.PublicationCommitmentSet memory commitments =
            _commitmentsAndBind(
                publication,
                phases,
                address(receiver),
                true
            );

        publication.setOfficialPublication(false);
        VM.expectPartialRevert(HellboxPrimarySale.UnofficialPublication.selector);
        new HellboxPrimarySale(
            address(publication),
            address(receiver),
            true,
            commitments,
            phases
        );

        publication.setOfficialPublication(true);
        publication.setMaxPerTransaction(2);
        VM.expectPartialRevert(
            HellboxPrimarySale.UnsupportedPublicationTransactionShape.selector
        );
        new HellboxPrimarySale(
            address(publication),
            address(receiver),
            true,
            commitments,
            phases
        );
    }

    function testPrizePolicyAndRouterShapeAreFrozen() public {
        VM.warp(START);
        PrimarySaleProceedsReceiver receiver = new PrimarySaleProceedsReceiver();
        PrimarySaleTokenMock token = new PrimarySaleTokenMock();
        PrimarySalePublicationMock publication =
            new PrimarySalePublicationMock(START + 20_000);
        HellboxPrimarySale.Phase[] memory phases =
            _standardPhases(address(publication), address(token));
        HellboxPrimarySale.PublicationCommitmentSet memory commitments =
            _commitmentSet(phases, address(receiver), false);
        publication.setCommitmentsDigest(keccak256(abi.encode(commitments)));

        VM.expectPartialRevert(
            HellboxPrimarySale.PrizeBootstrapPolicyMismatch.selector
        );
        new HellboxPrimarySale(
            address(publication),
            address(receiver),
            false,
            commitments,
            phases
        );

        commitments = _commitmentSet(phases, ALICE, true);
        publication.setCommitmentsDigest(keccak256(abi.encode(commitments)));
        VM.expectPartialRevert(
            HellboxPrimarySale.InvalidProceedsReceiver.selector
        );
        new HellboxPrimarySale(
            address(publication),
            ALICE,
            true,
            commitments,
            phases
        );
    }

    function testAllFreePublicationRequiresNoProceedsRouter() public {
        VM.warp(START);
        PrimarySalePublicationMock publication =
            new PrimarySalePublicationMock(0);
        publication.configureProfile(1, 1, 0, 0, 0, 1);
        HellboxPrimarySale.Phase[] memory phases = _freeOnlyPhases();
        HellboxPrimarySale.PublicationCommitmentSet memory commitments =
            _commitmentsAndBind(publication, phases, address(0), false);

        HellboxPrimarySale sale = new HellboxPrimarySale(
            address(publication),
            address(0),
            false,
            commitments,
            phases
        );
        publication.setSale(address(sale));
        require(sale.proceedsReceiver() == address(0), "free receiver");
        require(sale.collectorRequestCapacity() == 1, "free capacity");

        bytes32[] memory noProof = new bytes32[](0);
        VM.prank(ALICE, ALICE);
        (uint256 requestId,) = sale.requestPrimary(FREE_PHASE, noProof);
        publication.fulfillCollectorRequest(requestId, 1);
        require(sale.fulfilledCollectorRequests() == 1, "free fulfilled");

        PrimarySaleProceedsReceiver receiver = new PrimarySaleProceedsReceiver();
        VM.expectPartialRevert(
            HellboxPrimarySale.UnexpectedProceedsReceiver.selector
        );
        new HellboxPrimarySale(
            address(publication),
            address(receiver),
            false,
            commitments,
            phases
        );
    }

    function testPrizeWalletMustFinishBeforeCollectorCheckout() public {
        StandardDeployment memory deployment = _deployStandard();
        bytes32[] memory noProof = new bytes32[](0);

        VM.expectPartialRevert(
            HellboxPrimarySale.PrizeWalletBootstrapIncomplete.selector
        );
        VM.prank(ALICE, ALICE);
        deployment.sale.requestPrimary(FREE_PHASE, noProof);

        deployment.publication.setPrizeWalletIssuanceComplete(true);
        VM.prank(ALICE, ALICE);
        (uint256 requestId,) =
            deployment.sale.requestPrimary(FREE_PHASE, noProof);
        require(requestId == 8, "first collector request");
    }

    function testFreeCheckoutIsSelfOnlyAndTracksPendingAllowance() public {
        StandardDeployment memory deployment = _deployReadyStandard();
        bytes32[] memory noProof = new bytes32[](0);

        VM.prank(ALICE, ALICE);
        (uint256 requestId, uint64 round) =
            deployment.sale.requestPrimary(FREE_PHASE, noProof);

        require(requestId == 8, "request id");
        require(round == 10_008, "round");
        require(deployment.sale.totalCollectorRequests() == 1, "total");
        require(deployment.sale.pendingCollectorRequests() == 1, "pending");
        require(
            deployment.sale.walletPendingRequests(ALICE) == 1,
            "wallet pending"
        );
        require(
            deployment.sale.phasePendingRequestCount(FREE_PHASE) == 1,
            "phase pending"
        );
        require(
            deployment.sale.phaseWalletPendingRequestCount(
                FREE_PHASE,
                ALICE
            ) == 1,
            "phase wallet pending"
        );

        (
            address requestAccount,
            address requestRecipient,
            bool fulfilled
        ) = deployment.publication.mockRequestById(requestId);
        require(requestAccount == ALICE, "primary account");
        require(requestRecipient == ALICE, "self recipient");
        require(!fulfilled, "premature fulfillment");

        VM.expectPartialRevert(
            HellboxPrimarySale.PhaseWalletCapExceeded.selector
        );
        VM.prank(ALICE, ALICE);
        deployment.sale.requestPrimary(FREE_PHASE, noProof);
    }

    function testContractCollectorCannotFreezeTheFifoQueue() public {
        StandardDeployment memory deployment = _deployReadyStandard();
        PrimarySaleContractCollector blocker =
            new PrimarySaleContractCollector();

        VM.expectPartialRevert(HellboxPrimarySale.DirectEoaRequired.selector);
        blocker.requestFree(deployment.sale, FREE_PHASE);

        require(deployment.sale.totalCollectorRequests() == 0, "sale count");
        require(deployment.publication.requestCount() == 7, "queue count");
        require(deployment.sale.pendingCollectorRequests() == 0, "pending");
    }

    function testConstructorCallerCannotBypassDirectWalletRule() public {
        StandardDeployment memory deployment = _deployReadyStandard();

        VM.expectPartialRevert(HellboxPrimarySale.DirectEoaRequired.selector);
        new PrimarySaleConstructorCollector(deployment.sale, FREE_PHASE);

        require(deployment.sale.totalCollectorRequests() == 0, "sale count");
        require(deployment.publication.requestCount() == 7, "queue count");
        require(deployment.sale.pendingCollectorRequests() == 0, "pending");
    }

    function testMaximumPhaseConfigurationCanDeploy() public {
        VM.warp(START);
        PrimarySalePublicationMock publication =
            new PrimarySalePublicationMock(START + 20_000);
        HellboxPrimarySale.Phase[] memory phases =
            new HellboxPrimarySale.Phase[](32);

        for (uint256 i = 0; i < phases.length; ++i) {
            phases[i] = HellboxPrimarySale.Phase({
                phaseId: keccak256(abi.encode("MAX_PHASE", i)),
                startAt: 0,
                endAt: 0,
                phaseCap: 206,
                phaseWalletCap: 6,
                pricingMode: HellboxPrimarySale.PricingMode.FREE,
                token: address(0),
                exactAmount: 0,
                merkleRoot: bytes32(0)
            });
        }

        HellboxPrimarySale.PublicationCommitmentSet memory commitments =
            _commitmentsAndBind(publication, phases, address(0), true);
        HellboxPrimarySale sale = new HellboxPrimarySale(
            address(publication),
            address(0),
            true,
            commitments,
            phases
        );

        require(sale.phaseCount() == 32, "maximum phases");
    }

    function testPublicPhaseRejectsProofAndFreePhaseRejectsValue() public {
        StandardDeployment memory deployment = _deployReadyStandard();
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = bytes32(uint256(1));

        VM.expectPartialRevert(
            HellboxPrimarySale.UnexpectedEligibilityProof.selector
        );
        VM.prank(ALICE, ALICE);
        deployment.sale.requestPrimary(FREE_PHASE, proof);

        VM.deal(ALICE, 1 ether);
        bytes32[] memory noProof = new bytes32[](0);
        VM.expectPartialRevert(
            HellboxPrimarySale.UnexpectedNativeValue.selector
        );
        VM.prank(ALICE, ALICE);
        deployment.sale.requestPrimary{value: 1}(FREE_PHASE, noProof);
    }

    function testNativePaymentStaysEscrowedUntilFulfillment() public {
        StandardDeployment memory deployment = _deployReadyStandard();
        bytes32[] memory noProof = new bytes32[](0);
        VM.warp(START + 150);
        VM.deal(ALICE, 10 ether);

        VM.expectPartialRevert(
            HellboxPrimarySale.IncorrectNativePayment.selector
        );
        VM.prank(ALICE, ALICE);
        deployment.sale.requestPrimary{value: NATIVE_PRICE - 1}(
            NATIVE_PHASE,
            noProof
        );

        VM.expectPartialRevert(
            HellboxPrimarySale.IncorrectNativePayment.selector
        );
        VM.prank(ALICE, ALICE);
        deployment.sale.requestPrimary{value: NATIVE_PRICE + 1}(
            NATIVE_PHASE,
            noProof
        );

        uint256 receiverBefore = address(deployment.receiver).balance;
        VM.prank(ALICE, ALICE);
        (uint256 requestId,) =
            deployment.sale.requestPrimary{value: NATIVE_PRICE}(
                NATIVE_PHASE,
                noProof
            );

        require(address(deployment.sale).balance == NATIVE_PRICE, "escrow");
        require(
            deployment.sale.escrowedNative() == NATIVE_PRICE,
            "escrow ledger"
        );
        require(
            address(deployment.receiver).balance == receiverBefore,
            "released early"
        );

        VM.expectPartialRevert(HellboxPrimarySale.RequestNotFulfilled.selector);
        deployment.sale.releasePayment(requestId);
    }

    function testNativeReleaseIsPermissionlessAndRetryable() public {
        StandardDeployment memory deployment = _deployReadyStandard();
        bytes32[] memory noProof = new bytes32[](0);
        VM.warp(START + 150);
        VM.deal(ALICE, 10 ether);

        VM.prank(ALICE, ALICE);
        (uint256 requestId,) =
            deployment.sale.requestPrimary{value: NATIVE_PRICE}(
                NATIVE_PHASE,
                noProof
            );
        deployment.publication.fulfillCollectorRequest(requestId, 77);

        require(deployment.sale.pendingCollectorRequests() == 0, "pending");
        require(
            deployment.sale.fulfilledCollectorRequests() == 1,
            "fulfilled"
        );
        require(
            deployment.sale.walletPendingRequests(ALICE) == 0,
            "wallet pending"
        );
        require(
            deployment.publication.walletLifetimePrimaryUsed(ALICE) == 1,
            "publication usage"
        );

        deployment.receiver.setAcceptsNative(false);
        VM.expectPartialRevert(bytes4(keccak256("FailedCall()")));
        VM.prank(BOB, BOB);
        deployment.sale.releasePayment(requestId);
        require(
            deployment.sale.escrowedNative() == NATIVE_PRICE,
            "retry escrow"
        );

        deployment.receiver.setAcceptsNative(true);
        uint256 receiverBefore = address(deployment.receiver).balance;
        VM.prank(BOB, BOB);
        deployment.sale.releasePayment(requestId);
        require(
            address(deployment.receiver).balance == receiverBefore + NATIVE_PRICE,
            "released"
        );
        require(deployment.sale.escrowedNative() == 0, "ledger cleared");
        require(deployment.sale.releasedPayments() == 1, "release count");

        VM.expectPartialRevert(
            HellboxPrimarySale.PaymentAlreadyReleased.selector
        );
        deployment.sale.releasePayment(requestId);
    }

    function testERC20CheckoutRequiresEligibilityAndExactReceipt() public {
        StandardDeployment memory deployment = _deployReadyStandard();
        bytes32[] memory noProof = new bytes32[](0);

        VM.expectPartialRevert(
            HellboxPrimarySale.InvalidEligibilityProof.selector
        );
        VM.prank(BOB, BOB);
        deployment.sale.requestPrimary(ERC20_PHASE, noProof);

        deployment.token.mint(ALICE, TOKEN_PRICE);
        VM.prank(ALICE, ALICE);
        deployment.token.approve(address(deployment.sale), TOKEN_PRICE);

        VM.prank(ALICE, ALICE);
        (uint256 requestId,) =
            deployment.sale.requestPrimary(ERC20_PHASE, noProof);
        require(requestId == 8, "request");
        require(
            deployment.token.balanceOf(address(deployment.sale)) == TOKEN_PRICE,
            "token escrow"
        );
        require(
            deployment.sale.escrowedToken(address(deployment.token)) ==
                TOKEN_PRICE,
            "token ledger"
        );
        require(
            deployment.token.balanceOf(address(deployment.receiver)) == 0,
            "released early"
        );
    }

    function testFeeOnTransferDepositRollsBackEverything() public {
        VM.warp(START);
        PrimarySaleTokenMock token = new PrimarySaleTokenMock();
        token.setShortTransferFrom(true);
        (
            HellboxPrimarySale sale,
            PrimarySalePublicationMock publication,
            PrimarySaleProceedsReceiver receiver
        ) = _deployOnePhase(
            address(token),
            HellboxPrimarySale.PricingMode.FIXED_ERC20,
            TOKEN_PRICE,
            bytes32(0),
            10,
            6,
            true
        );
        require(address(receiver) != address(0), "receiver fixture");
        publication.setPrizeWalletIssuanceComplete(true);

        token.mint(ALICE, TOKEN_PRICE);
        VM.prank(ALICE, ALICE);
        token.approve(address(sale), TOKEN_PRICE);

        bytes32[] memory noProof = new bytes32[](0);
        VM.expectPartialRevert(
            HellboxPrimarySale.ERC20ReceiptMismatch.selector
        );
        VM.prank(ALICE, ALICE);
        sale.requestPrimary(ERC20_PHASE, noProof);

        require(publication.requestCount() == 7, "publication rollback");
        require(sale.totalCollectorRequests() == 0, "request rollback");
        require(sale.pendingCollectorRequests() == 0, "pending rollback");
        require(token.balanceOf(ALICE) == TOKEN_PRICE, "buyer rollback");
        require(token.balanceOf(address(sale)) == 0, "escrow rollback");
    }

    function testERC20ReleaseIsAuthenticatedExactAndRetryable() public {
        StandardDeployment memory deployment = _deployReadyStandard();
        bytes32[] memory noProof = new bytes32[](0);
        deployment.token.mint(ALICE, TOKEN_PRICE);
        VM.prank(ALICE, ALICE);
        deployment.token.approve(address(deployment.sale), TOKEN_PRICE);

        VM.prank(ALICE, ALICE);
        (uint256 requestId,) =
            deployment.sale.requestPrimary(ERC20_PHASE, noProof);

        VM.expectPartialRevert(
            HellboxPrimarySale.UnauthorizedPublicationCallback.selector
        );
        deployment.sale.onCollectorPrimaryFulfilled(
            requestId,
            ALICE,
            ALICE,
            88
        );

        deployment.publication.fulfillCollectorRequest(requestId, 88);
        deployment.token.setShortTransfer(true);
        VM.expectPartialRevert(
            HellboxPrimarySale.ERC20ReleaseMismatch.selector
        );
        VM.prank(BOB, BOB);
        deployment.sale.releasePayment(requestId);
        require(
            deployment.token.balanceOf(address(deployment.sale)) == TOKEN_PRICE,
            "retry token escrow"
        );

        deployment.token.setShortTransfer(false);
        VM.prank(BOB, BOB);
        deployment.sale.releasePayment(requestId);
        require(
            deployment.token.balanceOf(address(deployment.receiver)) ==
                TOKEN_PRICE,
            "receiver tokens"
        );
        require(
            deployment.sale.escrowedToken(address(deployment.token)) == 0,
            "token ledger"
        );
    }

    function testPublicationRequestFailureRollsBackNativeEscrow() public {
        StandardDeployment memory deployment = _deployReadyStandard();
        deployment.publication.setRejectCollectorRequests(true);
        bytes32[] memory noProof = new bytes32[](0);
        VM.warp(START + 150);
        VM.deal(ALICE, 10 ether);

        VM.expectPartialRevert(
            PrimarySalePublicationMock.CollectorRequestRejected.selector
        );
        VM.prank(ALICE, ALICE);
        deployment.sale.requestPrimary{value: NATIVE_PRICE}(
            NATIVE_PHASE,
            noProof
        );

        require(deployment.sale.totalCollectorRequests() == 0, "total");
        require(deployment.sale.pendingCollectorRequests() == 0, "pending");
        require(deployment.sale.escrowedNative() == 0, "ledger");
        require(address(deployment.sale).balance == 0, "balance");
    }

    function testPhaseWindowDeadlineAndPermanentCloseFailClosed() public {
        StandardDeployment memory deployment = _deployReadyStandard();
        bytes32[] memory noProof = new bytes32[](0);
        VM.deal(ALICE, 20 ether);

        VM.warp(START + 99);
        VM.expectPartialRevert(HellboxPrimarySale.PhaseInactive.selector);
        VM.prank(ALICE, ALICE);
        deployment.sale.requestPrimary{value: NATIVE_PRICE}(
            NATIVE_PHASE,
            noProof
        );

        VM.warp(START + 200);
        VM.expectPartialRevert(HellboxPrimarySale.PhaseInactive.selector);
        VM.prank(ALICE, ALICE);
        deployment.sale.requestPrimary{value: NATIVE_PRICE}(
            NATIVE_PHASE,
            noProof
        );

        VM.warp(START + 20_000);
        VM.expectPartialRevert(
            HellboxPrimarySale.NativeMintWindowClosed.selector
        );
        VM.prank(ALICE, ALICE);
        deployment.sale.requestPrimary(FREE_PHASE, noProof);

        VM.warp(START + 1);
        deployment.publication.setPrimaryIssuanceClosed(true);
        VM.expectPartialRevert(
            HellboxPrimarySale.PublicationIssuanceClosed.selector
        );
        VM.prank(ALICE, ALICE);
        deployment.sale.requestPrimary(FREE_PHASE, noProof);
    }

    function testPublicationCapacityCannotBeOversubscribed() public {
        VM.warp(START);
        (
            HellboxPrimarySale sale,
            PrimarySalePublicationMock publication,
            PrimarySaleProceedsReceiver receiver
        ) = _deployOnePhase(
            address(0),
            HellboxPrimarySale.PricingMode.FREE,
            0,
            bytes32(0),
            3,
            3,
            true
        );
        require(address(receiver) != address(0), "fixture");
        publication.setPrizeWalletIssuanceComplete(true);
        publication.setNonTailIssuanceRemaining(2);
        bytes32[] memory noProof = new bytes32[](0);

        VM.prank(ALICE, ALICE);
        sale.requestPrimary(FREE_PHASE, noProof);
        VM.prank(BOB, BOB);
        sale.requestPrimary(FREE_PHASE, noProof);

        VM.expectPartialRevert(
            HellboxPrimarySale.PublicationCapacityReserved.selector
        );
        VM.prank(CAROL, CAROL);
        sale.requestPrimary(FREE_PHASE, noProof);
    }

    function testPhaseCapCannotBeOversubscribed() public {
        VM.warp(START);
        (
            HellboxPrimarySale sale,
            PrimarySalePublicationMock publication,
            PrimarySaleProceedsReceiver receiver
        ) = _deployOnePhase(
            address(0),
            HellboxPrimarySale.PricingMode.FREE,
            0,
            bytes32(0),
            2,
            2,
            true
        );
        require(address(receiver) != address(0), "fixture");
        publication.setPrizeWalletIssuanceComplete(true);
        bytes32[] memory noProof = new bytes32[](0);

        VM.prank(ALICE, ALICE);
        sale.requestPrimary(FREE_PHASE, noProof);
        VM.prank(BOB, BOB);
        sale.requestPrimary(FREE_PHASE, noProof);

        VM.expectPartialRevert(HellboxPrimarySale.PhaseCapExceeded.selector);
        VM.prank(CAROL, CAROL);
        sale.requestPrimary(FREE_PHASE, noProof);
    }

    function testLifetimeCapCountsIssuedAndPendingTogether() public {
        VM.warp(START);
        (
            HellboxPrimarySale sale,
            PrimarySalePublicationMock publication,
            PrimarySaleProceedsReceiver receiver
        ) = _deployOnePhase(
            address(0),
            HellboxPrimarySale.PricingMode.FREE,
            0,
            bytes32(0),
            10,
            6,
            true
        );
        require(address(receiver) != address(0), "fixture");
        publication.setPrizeWalletIssuanceComplete(true);
        publication.setWalletLifetimePrimaryUsed(ALICE, 5);
        bytes32[] memory noProof = new bytes32[](0);

        VM.prank(ALICE, ALICE);
        sale.requestPrimary(FREE_PHASE, noProof);

        VM.expectPartialRevert(HellboxPrimarySale.LifetimeCapExceeded.selector);
        VM.prank(ALICE, ALICE);
        sale.requestPrimary(FREE_PHASE, noProof);
    }

    function testCallbackBindingDuplicateTokenAndDoubleFulfillmentFailClosed()
        public
    {
        StandardDeployment memory deployment = _deployReadyStandard();
        bytes32[] memory noProof = new bytes32[](0);
        VM.prank(ALICE, ALICE);
        (uint256 firstRequestId,) =
            deployment.sale.requestPrimary(FREE_PHASE, noProof);
        VM.prank(BOB, BOB);
        (uint256 secondRequestId,) =
            deployment.sale.requestPrimary(FREE_PHASE, noProof);

        VM.expectPartialRevert(
            HellboxPrimarySale.PublicationCallbackMismatch.selector
        );
        deployment.publication.callbackWith(
            firstRequestId,
            BOB,
            BOB,
            99
        );

        deployment.publication.fulfillCollectorRequest(firstRequestId, 99);

        VM.expectPartialRevert(
            HellboxPrimarySale.DuplicateIssuedTokenId.selector
        );
        deployment.publication.callbackWith(
            secondRequestId,
            BOB,
            BOB,
            99
        );

        VM.expectPartialRevert(
            HellboxPrimarySale.PublicationRequestAlreadyFulfilled.selector
        );
        deployment.publication.callbackWith(
            firstRequestId,
            ALICE,
            ALICE,
            100
        );
    }

    function testFreeFulfillmentSettlesWithoutReleaseAndDirectValueFails()
        public
    {
        StandardDeployment memory deployment = _deployReadyStandard();
        bytes32[] memory noProof = new bytes32[](0);
        VM.prank(ALICE, ALICE);
        (uint256 requestId,) =
            deployment.sale.requestPrimary(FREE_PHASE, noProof);
        deployment.publication.fulfillCollectorRequest(requestId, 55);

        (
            bytes32 phaseId,
            address account,
            HellboxPrimarySale.PricingMode pricingMode,
            address token,
            uint256 amount,
            uint64 randomnessRound,
            uint256 tokenId,
            HellboxPrimarySale.RequestState state
        ) = deployment.sale.requestById(requestId);
        require(phaseId == FREE_PHASE, "phase");
        require(account == ALICE, "account");
        require(pricingMode == HellboxPrimarySale.PricingMode.FREE, "mode");
        require(token == address(0), "token");
        require(amount == 0, "amount");
        require(randomnessRound == 10_008, "round");
        require(tokenId == 55, "token id");
        require(state == HellboxPrimarySale.RequestState.SETTLED, "state");

        VM.expectPartialRevert(HellboxPrimarySale.RequestHasNoEscrow.selector);
        deployment.sale.releasePayment(requestId);

        VM.deal(ALICE, 1 ether);
        VM.prank(ALICE, ALICE);
        (bool success,) = address(deployment.sale).call{value: 1}("");
        require(!success, "direct value accepted");
    }

    function _deployStandard()
        internal
        returns (StandardDeployment memory deployment)
    {
        VM.warp(START);
        deployment.receiver = new PrimarySaleProceedsReceiver();
        deployment.token = new PrimarySaleTokenMock();
        deployment.publication =
            new PrimarySalePublicationMock(START + 20_000);

        HellboxPrimarySale.Phase[] memory phases = _standardPhases(
            address(deployment.publication),
            address(deployment.token)
        );
        HellboxPrimarySale.PublicationCommitmentSet memory commitments =
            _commitmentsAndBind(
                deployment.publication,
                phases,
                address(deployment.receiver),
                true
            );

        deployment.sale = new HellboxPrimarySale(
            address(deployment.publication),
            address(deployment.receiver),
            true,
            commitments,
            phases
        );
        deployment.publication.setSale(address(deployment.sale));
    }

    function _deployReadyStandard()
        internal
        returns (StandardDeployment memory deployment)
    {
        deployment = _deployStandard();
        deployment.publication.setPrizeWalletIssuanceComplete(true);
    }

    function _deployOnePhase(
        address token,
        HellboxPrimarySale.PricingMode pricingMode,
        uint256 exactAmount,
        bytes32 merkleRoot,
        uint256 phaseCap,
        uint256 walletCap,
        bool prizeRequired
    )
        internal
        returns (
            HellboxPrimarySale sale,
            PrimarySalePublicationMock publication,
            PrimarySaleProceedsReceiver receiver
        )
    {
        receiver = new PrimarySaleProceedsReceiver();
        publication = new PrimarySalePublicationMock(START + 20_000);

        HellboxPrimarySale.Phase[] memory phases =
            new HellboxPrimarySale.Phase[](1);
        bytes32 phaseId = pricingMode ==
            HellboxPrimarySale.PricingMode.FIXED_ERC20
            ? ERC20_PHASE
            : pricingMode == HellboxPrimarySale.PricingMode.FIXED_NATIVE
                ? NATIVE_PHASE
                : FREE_PHASE;
        phases[0] = HellboxPrimarySale.Phase({
            phaseId: phaseId,
            startAt: 0,
            endAt: 0,
            phaseCap: phaseCap,
            phaseWalletCap: walletCap,
            pricingMode: pricingMode,
            token: token,
            exactAmount: exactAmount,
            merkleRoot: merkleRoot
        });

        address configuredReceiver = pricingMode ==
            HellboxPrimarySale.PricingMode.FREE
            ? address(0)
            : address(receiver);
        HellboxPrimarySale.PublicationCommitmentSet memory commitments =
            _commitmentsAndBind(
                publication,
                phases,
                configuredReceiver,
                prizeRequired
            );
        sale = new HellboxPrimarySale(
            address(publication),
            configuredReceiver,
            prizeRequired,
            commitments,
            phases
        );
        publication.setSale(address(sale));
    }

    function _standardPhases(
        address publicationAndFactory,
        address token
    )
        internal
        view
        returns (HellboxPrimarySale.Phase[] memory phases)
    {
        phases = new HellboxPrimarySale.Phase[](3);
        phases[0] = HellboxPrimarySale.Phase({
            phaseId: FREE_PHASE,
            startAt: 0,
            endAt: 0,
            phaseCap: 2,
            phaseWalletCap: 1,
            pricingMode: HellboxPrimarySale.PricingMode.FREE,
            token: address(0),
            exactAmount: 0,
            merkleRoot: bytes32(0)
        });
        phases[1] = HellboxPrimarySale.Phase({
            phaseId: NATIVE_PHASE,
            startAt: uint64(START + 100),
            endAt: uint64(START + 200),
            phaseCap: 2,
            phaseWalletCap: 2,
            pricingMode: HellboxPrimarySale.PricingMode.FIXED_NATIVE,
            token: address(0),
            exactAmount: NATIVE_PRICE,
            merkleRoot: bytes32(0)
        });
        phases[2] = HellboxPrimarySale.Phase({
            phaseId: ERC20_PHASE,
            startAt: 0,
            endAt: 0,
            phaseCap: 3,
            phaseWalletCap: 1,
            pricingMode: HellboxPrimarySale.PricingMode.FIXED_ERC20,
            token: token,
            exactAmount: TOKEN_PRICE,
            merkleRoot: _leaf(
                publicationAndFactory,
                ERC20_PHASE,
                ALICE
            )
        });
    }

    function _freeOnlyPhases()
        internal
        pure
        returns (HellboxPrimarySale.Phase[] memory phases)
    {
        phases = new HellboxPrimarySale.Phase[](1);
        phases[0] = HellboxPrimarySale.Phase({
            phaseId: FREE_PHASE,
            startAt: 0,
            endAt: 0,
            phaseCap: 1,
            phaseWalletCap: 1,
            pricingMode: HellboxPrimarySale.PricingMode.FREE,
            token: address(0),
            exactAmount: 0,
            merkleRoot: bytes32(0)
        });
    }

    function _commitmentsAndBind(
        PrimarySalePublicationMock publication,
        HellboxPrimarySale.Phase[] memory phases,
        address receiver,
        bool prizeRequired
    )
        internal
        returns (
            HellboxPrimarySale.PublicationCommitmentSet memory commitments
        )
    {
        commitments = _commitmentSet(phases, receiver, prizeRequired);
        publication.setCommitmentsDigest(keccak256(abi.encode(commitments)));
    }

    function _commitmentSet(
        HellboxPrimarySale.Phase[] memory phases,
        address receiver,
        bool prizeRequired
    )
        internal
        pure
        returns (
            HellboxPrimarySale.PublicationCommitmentSet memory commitments
        )
    {
        (
            bytes32 pricing,
            bytes32 routes,
            bytes32 mintPhases
        ) = _configurationDigests(phases, receiver, prizeRequired);

        commitments = HellboxPrimarySale.PublicationCommitmentSet({
            publicationManifestDigest: keccak256("publication-manifest"),
            packageDigest: keccak256("package"),
            fixedCopyRulesDigest: keccak256("fixed-copy-rules"),
            birthTraitsDigest: keccak256("birth-traits"),
            randomizationPolicyDigest: keccak256("randomization-policy"),
            rendererRulesDigest: keccak256("renderer-rules"),
            readerPolicyDigest: keccak256("reader-policy"),
            pricingPoliciesDigest: pricing,
            paymentRoutesDigest: routes,
            mintPhasesDigest: mintPhases,
            royaltyPolicyDigest: keccak256("royalty-policy"),
            treasuryPolicyDigest: keccak256("treasury-policy"),
            metadataPolicyDigest: keccak256("metadata-policy"),
            capabilityPolicyDigest: keccak256("capability-policy"),
            protocolCompatibilityDigest: keccak256("protocol-compatibility"),
            closurePolicyDigest: keccak256("closure-policy"),
            authorityPolicyDigest: keccak256("authority-policy"),
            eventPolicyDigest: keccak256("event-policy")
        });
    }

    function _configurationDigests(
        HellboxPrimarySale.Phase[] memory phases,
        address receiver,
        bool prizeRequired
    )
        internal
        pure
        returns (
            bytes32 pricingDigest,
            bytes32 routesDigest,
            bytes32 mintPhasesDigest
        )
    {
        uint256 count = phases.length;
        HellboxPrimarySale.PricingCommitment[] memory pricing =
            new HellboxPrimarySale.PricingCommitment[](count);
        HellboxPrimarySale.PaymentRouteCommitment[] memory routes =
            new HellboxPrimarySale.PaymentRouteCommitment[](count);
        HellboxPrimarySale.MintPhaseCommitment[] memory mintPhases =
            new HellboxPrimarySale.MintPhaseCommitment[](count);

        for (uint256 i = 0; i < count; ++i) {
            HellboxPrimarySale.Phase memory phase = phases[i];
            pricing[i] = HellboxPrimarySale.PricingCommitment({
                phaseId: phase.phaseId,
                pricingMode: phase.pricingMode,
                exactAmount: phase.exactAmount
            });
            routes[i] = HellboxPrimarySale.PaymentRouteCommitment({
                phaseId: phase.phaseId,
                pricingMode: phase.pricingMode,
                token: phase.token,
                proceedsReceiver: phase.pricingMode ==
                    HellboxPrimarySale.PricingMode.FREE
                    ? address(0)
                    : receiver,
                exactPaymentPolicy: phase.pricingMode ==
                    HellboxPrimarySale.PricingMode.FREE
                    ? bytes32(0)
                    : keccak256("EXACT_OR_REVERT"),
                tokenCompatibilityPolicy: phase.pricingMode ==
                    HellboxPrimarySale.PricingMode.FIXED_ERC20
                    ? keccak256("EXACT_TRANSFER_V1")
                    : bytes32(0)
            });
            mintPhases[i] = HellboxPrimarySale.MintPhaseCommitment({
                phaseId: phase.phaseId,
                order: i,
                startAt: phase.startAt,
                endAt: phase.endAt,
                phaseCap: phase.phaseCap,
                phaseWalletCap: phase.phaseWalletCap,
                merkleRoot: phase.merkleRoot,
                eligibilityLeafSchemaVersion:
                    phase.merkleRoot == bytes32(0) ? 0 : 1
            });
        }

        pricingDigest = keccak256(
            abi.encode(
                keccak256("HELLBOX_ENFORCEMENT_V1:PRICING_POLICIES"),
                pricing
            )
        );
        routesDigest = keccak256(
            abi.encode(
                keccak256("HELLBOX_ENFORCEMENT_V1:PAYMENT_ROUTES"),
                routes
            )
        );
        mintPhasesDigest = keccak256(
            abi.encode(
                keccak256("HELLBOX_ENFORCEMENT_V1:MINT_PHASES"),
                prizeRequired,
                keccak256("SELF_ONLY"),
                keccak256("DIRECT_EOA"),
                keccak256("SHARED_POOL"),
                keccak256("SHARED_REMAINDER"),
                keccak256("GLOBAL_SHARED"),
                mintPhases
            )
        );
    }

    function _leaf(
        address publicationAndFactory,
        bytes32 phaseId,
        address account
    ) internal view returns (bytes32) {
        bytes32 inner = keccak256(
            abi.encode(
                keccak256("HELLBOX_PRIMARY_SALE_V1:ELIGIBILITY_LEAF"),
                block.chainid,
                publicationAndFactory,
                keccak256("release-config"),
                phaseId,
                account
            )
        );
        return keccak256(bytes.concat(inner));
    }
}
