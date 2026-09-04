// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {IERC721Receiver} from "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";
import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxPublicationFactory} from "../contracts/HellboxPublicationFactory.sol";
import {IHellboxRandomnessVerifier} from "../contracts/interfaces/IHellboxRandomnessVerifier.sol";

interface IProductionPrizeWalletVm {
    function addr(uint256 privateKey) external pure returns (address keyAddr);

    function sign(uint256 privateKey, bytes32 digest) external pure returns (uint8 v, bytes32 r, bytes32 s);

    function expectPartialRevert(bytes4 revertData) external;

    function mockCall(address callee, bytes calldata data, bytes calldata returnData) external;

    function mockCallRevert(address callee, bytes calldata data, bytes calldata revertData) external;

    function clearMockedCalls() external;

    function warp(uint256 newTimestamp) external;

    function etch(address target, bytes calldata newRuntimeBytecode) external;
}

/// @dev Creator recipient used to prove that ERC-721 receiver callbacks cannot
///      reenter either production initialization or FIFO fulfillment. The
///      callback catches both reverts so the legitimate outer mint can finish.
contract ReentrantCreatorReceiver is IERC721Receiver {
    address public publication;
    uint256 public callbackCount;
    bool public reentryAttempted;
    bool public beginCallSucceeded;
    bool public fulfillCallSucceeded;
    bytes4 public beginRevertSelector;
    bytes4 public fulfillRevertSelector;

    function arm(address publicationAddress) external {
        require(publication == address(0), "already armed");
        publication = publicationAddress;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4) {
        require(msg.sender == publication, "unexpected publication");
        ++callbackCount;

        if (!reentryAttempted) {
            reentryAttempted = true;

            bytes memory beginData;
            (beginCallSucceeded, beginData) =
                publication.call(abi.encodeWithSelector(HellboxPublication.beginCreatorInitialization.selector));
            beginRevertSelector = _selector(beginData);

            bytes memory fulfillData;
            (fulfillCallSucceeded, fulfillData) = publication.call(
                abi.encodeWithSelector(HellboxPublication.fulfillNextRandomnessRequest.selector, bytes(""))
            );
            fulfillRevertSelector = _selector(fulfillData);
        }

        return IERC721Receiver.onERC721Received.selector;
    }

    function _selector(bytes memory revertData) private pure returns (bytes4 selector) {
        if (revertData.length < 4) {
            return bytes4(0);
        }

        assembly ("memory-safe") {
            selector := mload(add(revertData, 0x20))
        }
    }
}

/// @dev Code used only with `vm.etch` to prove that a campaign EOA acquiring
///      runtime code after reservation is rejected before any receiver callback.
contract PrizeWalletCodeSentinel is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}

/// @notice Permanent real-factory composition and adversarial proof for the
///         production Prize Wallet orchestration committed in HellboxPublication.
/// @dev Every test deploys the exact production factory, publishes the exact
///      production publication through `publish(...)`, activates a campaign by
///      wallet EIP-712 self-signature, and uses generation-bound factory approval.
///      Only the verifier's `verifyRound` return is mocked so these tests can
///      deterministically exercise seven sequential future-round requests without
///      embedding seven historical drand proofs. Verifier identity, code hash,
///      provider digest, round schedule, factory code, and publication code remain
///      the production implementations.
contract HellboxProductionPrizeWalletIntegrationTest {
    IProductionPrizeWalletVm internal constant VM =
        IProductionPrizeWalletVm(address(uint160(uint256(keccak256("hevm cheat code")))));

    uint256 internal constant PRIZE_WALLET_KEY = 0xA11CE369;

    address internal constant CREATOR = 0x1111111111111111111111111111111111111111;
    address internal constant TAIL = 0x2222222222222222222222222222222222222222;
    address internal constant ROYALTY = 0x3333333333333333333333333333333333333333;
    address internal constant PUBLISHER = 0x4444444444444444444444444444444444444444;

    bytes32 internal constant RELEASE_CONFIG_DOMAIN = keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");
    bytes32 internal constant TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION");
    bytes32 internal constant DRAND_PROVIDER_CONFIG_DIGEST =
        0x0d191efbb2f605bf73b6f3c4819b21bc8c7a64393c6dcfd43b6b2f6b5be401e3;

    uint256 internal constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 internal constant CONFIG_SCHEMA_VERSION = 1;
    uint256 internal constant PUBLICATION_VERSION = 1;

    bytes32 internal constant MOCK_VERIFIED_RANDOMNESS = keccak256("hellbox-real-factory-integration-randomness");

    bytes4 internal constant VERIFY_ROUND_SELECTOR = IHellboxRandomnessVerifier.verifyRound.selector;

    error ForcedFactoryCompletionFailure();

    struct Deployment {
        HellboxPublicationFactory factory;
        HellboxPublication publication;
        address wallet;
        bytes32 campaignManifestDigest;
    }

    function testRealFactoryProductionFlowReservesFulfillsAndCompletes() public {
        Deployment memory deployed = _deployProductionPublication("real-factory-production-success", CREATOR, true);

        (uint256 firstRequestId, uint64 firstRound) = deployed.publication.beginCreatorInitialization();
        require(firstRequestId == 1, "first request id");
        require(firstRound != 0, "first request round");

        for (uint256 index = 0; index < 6; ++index) {
            uint256 expectedRequestId = index + 1;
            _assertPendingRequest(
                deployed.publication,
                expectedRequestId,
                HellboxPublication.RandomnessRequestKind.CREATOR_IMMEDIATE,
                CREATOR
            );

            (uint256 requestId, uint256 tokenId) = _fulfillPending(deployed.publication);

            require(requestId == expectedRequestId, "creator request order");
            require(tokenId == expectedRequestId, "creator token order");
            require(deployed.publication.ownerOf(tokenId) == CREATOR, "creator owner");
        }

        require(deployed.publication.immediateCreatorAllocationComplete(), "creator allocation incomplete");
        require(deployed.publication.totalPrimaryIssued() == 6, "creator total");
        require(deployed.publication.candidatePoolRemaining() == 210, "creator candidate total");
        require(deployed.publication.nonTailIssuanceRemaining() == 207, "creator non-tail total");

        _assertReservedState(deployed);
        _assertPendingRequest(
            deployed.publication, 7, HellboxPublication.RandomnessRequestKind.PRIZE_WALLET, deployed.wallet
        );

        (uint256 prizeRequestId, uint256 prizeTokenId) = _fulfillPending(deployed.publication);

        require(prizeRequestId == 7, "prize request id");
        require(deployed.publication.ownerOf(prizeTokenId) == deployed.wallet, "prize owner");
        require(deployed.publication.prizeWalletTokenId() == prizeTokenId, "prize token snapshot");
        require(deployed.publication.prizeWalletIssuanceComplete(), "prize issuance incomplete");
        require(deployed.publication.prizeWalletDepositCompleted(), "publication completion missing");
        require(deployed.publication.totalPrimaryIssued() == 7, "seventh mint");
        require(deployed.publication.candidatePoolRemaining() == 209, "post-prize candidates");
        require(deployed.publication.nonTailIssuanceRemaining() == 206, "post-prize non-tail");
        require(
            deployed.publication.randomnessRequestCount() == 7
                && deployed.publication.randomnessFulfillmentCount() == 7,
            "queue completion"
        );
        require(deployed.publication.nextPendingRandomnessRequestId() == 0, "queue not empty");

        _assertCompletedState(deployed);
    }

    function testRealFactoryReservationFailureRollsBackSixthCreatorFulfillment() public {
        Deployment memory deployed = _deployProductionPublication("real-factory-reservation-rollback", CREATOR, false);

        deployed.publication.beginCreatorInitialization();
        for (uint256 index = 0; index < 5; ++index) {
            _fulfillPending(deployed.publication);
        }

        require(deployed.publication.totalPrimaryIssued() == 5, "preflight total");
        require(deployed.publication.randomnessFulfillmentCount() == 5, "preflight fulfillment");

        uint256 requestId = deployed.publication.nextPendingRandomnessRequestId();
        require(requestId == 6, "sixth request missing");
        bytes memory proof = _proofForPending(deployed.publication, requestId);

        VM.expectPartialRevert(HellboxPublicationFactory.PrizeWalletPublicationNotApproved.selector);
        deployed.publication.fulfillNextRandomnessRequest(proof);

        require(deployed.publication.totalPrimaryIssued() == 5, "creator rollback");
        require(deployed.publication.immediateCreatorIssued() == 5, "creator count rollback");
        require(deployed.publication.balanceOf(CREATOR) == 5, "creator balance rollback");
        require(
            deployed.publication.randomnessRequestCount() == 6
                && deployed.publication.randomnessFulfillmentCount() == 5,
            "queue rollback"
        );
        require(deployed.publication.nextPendingRandomnessRequestId() == 6, "sixth request consumed");
        require(!deployed.publication.prizeWalletDepositReserved(), "publication reservation leaked");
        require(
            deployed.factory.prizeWalletDepositStateByPublication(address(deployed.publication))
                == deployed.factory.PRIZE_DEPOSIT_NONE(),
            "factory reservation leaked"
        );
        _assertCampaignCounts(deployed.factory, 1, 0, 0);
        _assertPendingRequest(
            deployed.publication, 6, HellboxPublication.RandomnessRequestKind.CREATOR_IMMEDIATE, CREATOR
        );

        uint256 approvedGeneration = deployed.factory.approvePrizeWalletPublication(address(deployed.publication));
        require(approvedGeneration == 1, "approval generation");

        (uint256 retriedRequestId, uint256 tokenId) = deployed.publication.fulfillNextRandomnessRequest(proof);

        require(retriedRequestId == 6, "request rerolled");
        require(tokenId == 6, "sixth token changed");
        require(deployed.publication.ownerOf(6) == CREATOR, "sixth creator owner");
        _assertReservedState(deployed);
        require(deployed.publication.nextPendingRandomnessRequestId() == 7, "prize request missing");
    }

    function testRealFactoryCompletionFailureRollsBackPrizeMintAndRetries() public {
        Deployment memory deployed = _deployProductionPublication("real-factory-completion-rollback", CREATOR, true);

        deployed.publication.beginCreatorInitialization();
        for (uint256 index = 0; index < 6; ++index) {
            _fulfillPending(deployed.publication);
        }
        _assertReservedState(deployed);

        uint256 requestId = deployed.publication.nextPendingRandomnessRequestId();
        require(requestId == 7, "prize request missing");
        bytes memory proof = _proofForPending(deployed.publication, requestId);

        VM.mockCallRevert(
            address(deployed.factory),
            abi.encodeWithSelector(HellboxPublicationFactory.completePrizeWalletDeposit.selector),
            abi.encodeWithSelector(ForcedFactoryCompletionFailure.selector)
        );

        VM.expectPartialRevert(ForcedFactoryCompletionFailure.selector);
        deployed.publication.fulfillNextRandomnessRequest(proof);

        VM.clearMockedCalls();
        _mockVerifier(deployed.publication);

        require(!deployed.publication.prizeWalletDepositCompleted(), "publication completion leaked");
        require(!deployed.publication.prizeWalletIssuanceComplete(), "prize state leaked");
        require(deployed.publication.prizeWalletTokenId() == 0, "prize token leaked");
        require(deployed.publication.balanceOf(deployed.wallet) == 0, "prize mint leaked");
        require(deployed.publication.totalPrimaryIssued() == 6, "supply leaked");
        require(deployed.publication.candidatePoolRemaining() == 210, "candidate mutation leaked");
        require(deployed.publication.nonTailIssuanceRemaining() == 207, "non-tail mutation leaked");
        require(
            deployed.publication.randomnessRequestCount() == 7
                && deployed.publication.randomnessFulfillmentCount() == 6,
            "request consumption leaked"
        );
        require(
            deployed.factory.prizeWalletDepositStateByPublication(address(deployed.publication))
                == deployed.factory.PRIZE_DEPOSIT_RESERVED(),
            "factory state changed"
        );
        _assertCampaignCounts(deployed.factory, 1, 1, 0);
        _assertPendingRequest(
            deployed.publication, 7, HellboxPublication.RandomnessRequestKind.PRIZE_WALLET, deployed.wallet
        );

        (uint256 retriedRequestId, uint256 prizeTokenId) = deployed.publication.fulfillNextRandomnessRequest(proof);

        require(retriedRequestId == 7, "prize request rerolled");
        require(deployed.publication.ownerOf(prizeTokenId) == deployed.wallet, "retry prize owner");
        _assertCompletedState(deployed);
    }

    function testCreatorReceiverReentrancyCannotDoubleStartOrFulfill() public {
        ReentrantCreatorReceiver receiver = new ReentrantCreatorReceiver();
        Deployment memory deployed =
            _deployProductionPublication("real-factory-creator-reentrancy", address(receiver), true);
        receiver.arm(address(deployed.publication));

        deployed.publication.beginCreatorInitialization();

        for (uint256 index = 0; index < 6; ++index) {
            _fulfillPending(deployed.publication);
        }

        require(receiver.reentryAttempted(), "reentry not attempted");
        require(!receiver.beginCallSucceeded(), "reentrant begin succeeded");
        require(!receiver.fulfillCallSucceeded(), "reentrant fulfill succeeded");
        require(
            receiver.beginRevertSelector() == HellboxPublication.RandomnessFulfillmentReentrancy.selector,
            "wrong begin reentry error"
        );
        require(
            receiver.fulfillRevertSelector() == HellboxPublication.RandomnessFulfillmentReentrancy.selector,
            "wrong fulfill reentry error"
        );
        require(receiver.callbackCount() == 6, "creator callback count");
        require(deployed.publication.balanceOf(address(receiver)) == 6, "creator receiver balance");
        require(deployed.publication.totalPrimaryIssued() == 6, "creator total");
        require(
            deployed.publication.randomnessRequestCount() == 7
                && deployed.publication.randomnessFulfillmentCount() == 6,
            "reentrant queue drift"
        );
        _assertReservedState(deployed);

        _fulfillPending(deployed.publication);
        _assertCompletedState(deployed);
    }

    function testCampaignWalletCodeAfterReservationFailsClosedAndRetries() public {
        Deployment memory deployed = _deployProductionPublication("real-factory-wallet-code-drift", CREATOR, true);

        deployed.publication.beginCreatorInitialization();
        for (uint256 index = 0; index < 6; ++index) {
            _fulfillPending(deployed.publication);
        }
        _assertReservedState(deployed);

        uint256 requestId = deployed.publication.nextPendingRandomnessRequestId();
        require(requestId == 7, "prize request missing");
        bytes memory proof = _proofForPending(deployed.publication, requestId);

        VM.etch(deployed.wallet, type(PrizeWalletCodeSentinel).runtimeCode);
        require(deployed.wallet.code.length != 0, "wallet code not installed");

        VM.expectPartialRevert(HellboxPublication.PrizeWalletRecipientHasCode.selector);
        deployed.publication.fulfillNextRandomnessRequest(proof);

        require(!deployed.publication.prizeWalletIssuanceComplete(), "prize state leaked");
        require(!deployed.publication.prizeWalletDepositCompleted(), "completion leaked");
        require(deployed.publication.totalPrimaryIssued() == 6, "supply leaked");
        require(deployed.publication.randomnessFulfillmentCount() == 6, "request consumed");
        require(
            deployed.factory.prizeWalletDepositStateByPublication(address(deployed.publication))
                == deployed.factory.PRIZE_DEPOSIT_RESERVED(),
            "factory reservation changed"
        );
        _assertCampaignCounts(deployed.factory, 1, 1, 0);
        _assertPendingRequest(
            deployed.publication, 7, HellboxPublication.RandomnessRequestKind.PRIZE_WALLET, deployed.wallet
        );

        VM.etch(deployed.wallet, hex"");
        require(deployed.wallet.code.length == 0, "wallet code not removed");

        (uint256 retriedRequestId, uint256 prizeTokenId) = deployed.publication.fulfillNextRandomnessRequest(proof);

        require(retriedRequestId == 7, "request rerolled");
        require(deployed.publication.ownerOf(prizeTokenId) == deployed.wallet, "retry prize owner");
        _assertCompletedState(deployed);
    }

    function _deployProductionPublication(
        string memory publicationKey,
        address creatorRecipient,
        bool approvePublication
    ) internal returns (Deployment memory deployed) {
        HellboxBirthPolicyCodeStore store = new HellboxBirthPolicyCodeStore();

        deployed.factory = new HellboxPublicationFactory(
            address(this),
            keccak256(type(HellboxPublication).creationCode),
            bytes32(uint256(2)),
            address(store),
            keccak256(type(HellboxBirthPolicy).creationCode)
        );

        deployed.wallet = VM.addr(PRIZE_WALLET_KEY);
        deployed.campaignManifestDigest =
            keccak256(abi.encode("HELLBOX_PRODUCTION_PRIZE_WALLET_INTEGRATION", publicationKey));
        _activateCampaign(deployed.factory, deployed.wallet, deployed.campaignManifestDigest);

        HellboxPublication.ReleaseConfig memory config = _nativeConfig(publicationKey, creatorRecipient);

        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthTraits,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _nativePolicies(creatorRecipient);

        HellboxPublication.CommitmentSet memory commitments = _commitments(fixedPolicy, birthTraits, randomPolicy);

        HellboxPublicationFactory.BirthPolicyPreimages memory preimages = HellboxPublicationFactory.BirthPolicyPreimages({
            fixedCopyPolicyPreimage: abi.encode(fixedPolicy),
            birthTraitsPolicyPreimage: abi.encode(birthTraits),
            randomizationPolicyPreimage: abi.encode(randomPolicy)
        });

        bytes32 releaseDigest = _releaseDigest(block.chainid, address(deployed.factory), config, commitments);

        deployed.publication = HellboxPublication(
            deployed.factory
                .publish(config, commitments, releaseDigest, preimages, type(HellboxPublication).creationCode)
        );

        require(deployed.factory.isPublication(address(deployed.publication)), "publication not registered");
        require(
            deployed.factory.publicationByReleaseDigest(releaseDigest) == address(deployed.publication),
            "release provenance"
        );
        require(deployed.publication.factory() == address(deployed.factory), "factory binding");
        require(deployed.publication.randomnessVerifier() == deployed.factory.randomnessVerifier(), "verifier binding");
        require(
            deployed.publication.randomnessVerifierRuntimeCodeHash()
                == deployed.factory.randomnessVerifierRuntimeCodeHash(),
            "verifier hash binding"
        );
        address verifierAddress = deployed.factory.randomnessVerifier();
        require(
            verifierAddress.codehash == deployed.factory.randomnessVerifierRuntimeCodeHash(),
            "factory verifier codehash"
        );
        require(
            deployed.publication.randomnessProviderConfigDigest() == DRAND_PROVIDER_CONFIG_DIGEST, "provider binding"
        );
        require(deployed.publication.issuanceStateInitialized(), "issuance bootstrap");

        if (approvePublication) {
            uint256 approvedGeneration = deployed.factory.approvePrizeWalletPublication(address(deployed.publication));
            require(approvedGeneration == 1, "approved generation");
        }

        _mockVerifier(deployed.publication);
    }

    function _activateCampaign(HellboxPublicationFactory factory, address wallet, bytes32 manifest) internal {
        uint256 deadline = block.timestamp + 1 days;
        bytes32 digest = factory.prizeWalletActivationDigest(1, wallet, manifest, deadline);
        (uint8 v, bytes32 r, bytes32 s) = VM.sign(PRIZE_WALLET_KEY, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        uint256 generation = factory.activatePrizeWalletCampaign(wallet, manifest, deadline, signature);

        require(generation == 1, "campaign generation");
        require(factory.activePrizeWallet() == wallet, "active wallet");
        require(factory.activePrizeWalletManifestDigest() == manifest, "active manifest");
    }

    function _mockVerifier(HellboxPublication publication) internal {
        VM.mockCall(
            publication.randomnessVerifier(),
            abi.encodeWithSelector(VERIFY_ROUND_SELECTOR),
            abi.encode(MOCK_VERIFIED_RANDOMNESS)
        );
    }

    function _fulfillPending(HellboxPublication publication) internal returns (uint256 requestId, uint256 tokenId) {
        requestId = publication.nextPendingRandomnessRequestId();
        require(requestId != 0, "no pending request");

        bytes memory proof = _proofForPending(publication, requestId);
        (uint256 fulfilledRequestId, uint256 issuedTokenId) = publication.fulfillNextRandomnessRequest(proof);

        require(fulfilledRequestId == requestId, "wrong request fulfilled");
        return (fulfilledRequestId, issuedTokenId);
    }

    function _proofForPending(HellboxPublication publication, uint256 requestId) internal returns (bytes memory proof) {
        uint64 round = _requestRound(publication, requestId);
        uint64 roundTimestamp = IHellboxRandomnessVerifier(publication.randomnessVerifier()).roundTimestamp(round);
        VM.warp(roundTimestamp);
        proof = abi.encode(round, MOCK_VERIFIED_RANDOMNESS);
    }

    function _requestRound(HellboxPublication publication, uint256 requestId) internal view returns (uint64 round) {
        (
            HellboxPublication.RandomnessRequestKind kind,
            uint64 storedRound,
            uint64 requestedAt,
            address primaryAccount,
            address recipient,
            bool fulfilled,
            uint256 tokenId,
            bytes32 verifiedRandomness
        ) = publication.randomnessRequestById(requestId);

        require(kind != HellboxPublication.RandomnessRequestKind.NONE, "kind");
        require(storedRound != 0, "round");
        require(requestedAt != 0 || block.timestamp == 0, "requested at");
        require(primaryAccount == address(0), "primary account");
        require(recipient != address(0), "recipient");
        require(!fulfilled, "already fulfilled");
        require(tokenId == 0, "token already set");
        require(verifiedRandomness == bytes32(0), "randomness already set");

        return storedRound;
    }

    function _assertPendingRequest(
        HellboxPublication publication,
        uint256 requestId,
        HellboxPublication.RandomnessRequestKind expectedKind,
        address expectedRecipient
    ) internal view {
        (
            HellboxPublication.RandomnessRequestKind kind,
            uint64 round,
            uint64 requestedAt,
            address primaryAccount,
            address recipient,
            bool fulfilled,
            uint256 tokenId,
            bytes32 verifiedRandomness
        ) = publication.randomnessRequestById(requestId);

        require(kind == expectedKind, "request kind");
        require(round != 0, "request round");
        require(requestedAt != 0 || block.timestamp == 0, "request time");
        require(primaryAccount == address(0), "request primary");
        require(recipient == expectedRecipient, "request recipient");
        require(!fulfilled, "request fulfilled");
        require(tokenId == 0, "request token");
        require(verifiedRandomness == bytes32(0), "request randomness");
    }

    function _assertReservedState(Deployment memory deployed) internal view {
        require(deployed.publication.prizeWalletDepositReserved(), "publication not reserved");
        require(!deployed.publication.prizeWalletDepositCompleted(), "publication completed early");
        require(deployed.publication.prizeWalletCampaignGeneration() == 1, "publication generation");
        require(
            deployed.publication.prizeWalletCampaignManifestDigest() == deployed.campaignManifestDigest,
            "publication manifest"
        );
        require(deployed.publication.prizeWalletRecipient() == deployed.wallet, "publication wallet");
        require(
            deployed.factory.prizeWalletDepositGenerationByPublication(address(deployed.publication)) == 1,
            "factory deposit generation"
        );
        require(
            deployed.factory.prizeWalletDepositStateByPublication(address(deployed.publication))
                == deployed.factory.PRIZE_DEPOSIT_RESERVED(),
            "factory not reserved"
        );
        _assertCampaignCounts(deployed.factory, 1, 1, 0);
    }

    function _assertCompletedState(Deployment memory deployed) internal view {
        require(deployed.publication.prizeWalletDepositCompleted(), "publication not completed");
        require(deployed.publication.prizeWalletIssuanceComplete(), "publication prize incomplete");
        require(
            deployed.factory.prizeWalletDepositStateByPublication(address(deployed.publication))
                == deployed.factory.PRIZE_DEPOSIT_COMPLETED(),
            "factory not completed"
        );
        _assertCampaignCounts(deployed.factory, 1, 0, 1);
    }

    function _assertCampaignCounts(
        HellboxPublicationFactory factory,
        uint256 generation,
        uint64 expectedPending,
        uint64 expectedCompleted
    ) internal view {
        (
            address wallet,
            bytes32 manifest,
            uint64 activatedAt,
            uint64 claimedAt,
            uint64 pendingDeposits,
            uint64 completedDeposits
        ) = factory.prizeWalletCampaignByGeneration(generation);

        require(wallet != address(0), "campaign wallet missing");
        require(manifest != bytes32(0), "campaign manifest missing");
        require(activatedAt != 0 || block.timestamp == 0, "campaign activation");
        require(claimedAt == 0, "campaign claimed");
        require(pendingDeposits == expectedPending, "campaign pending");
        require(completedDeposits == expectedCompleted, "campaign completed");
    }

    function _nativeConfig(string memory publicationKey, address creatorRecipient)
        internal
        pure
        returns (HellboxPublication.ReleaseConfig memory config)
    {
        config.publicationKey = publicationKey;
        config.collectionName = "Hellbox Native Issue #1";
        config.collectionSymbol = "HELL001";

        config.maxSupply = 216;
        config.primaryLifetimeCap = 6;
        config.maxPerTransaction = 1;

        config.immediateCreatorRecipient = creatorRecipient;
        config.immediateCreatorCount = 6;

        config.tailRecipient = TAIL;
        config.tailReserveCount = 3;

        config.royaltyReceiver = ROYALTY;
        config.royaltyBps = 369;

        config.publisherAuthority = PUBLISHER;

        config.readerEnabled = false;
        config.sealEnabled = false;
        config.archiveCompatible = false;
        config.dynamicMetadataEnabled = false;
        config.erc6551Compatible = false;
        config.rewardsCompatible = false;
        config.hellforgeCompatible = false;
        config.contextualTraitsEnabled = false;
    }

    function _nativePolicies(address creatorRecipient)
        internal
        pure
        returns (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        )
    {
        HellboxPublication.FixedCopyRuleEnforcement[] memory rules =
            new HellboxPublication.FixedCopyRuleEnforcement[](7);
        bytes32 creatorClass = keccak256("CREATOR_IMMEDIATE");
        bytes32 publicClass = keccak256("PUBLIC_RANDOM_POOL");
        bytes32 creatorReason = keccak256("HARROW_IMMEDIATE");

        rules[0] = _nativeRule(1, creatorClass, keccak256("HELLBOUND"), creatorRecipient, false, creatorReason);
        rules[1] = _nativeRule(2, creatorClass, keccak256("HELLBOUND"), creatorRecipient, false, creatorReason);
        rules[2] = _nativeRule(3, creatorClass, keccak256("PRESS_PROOF"), creatorRecipient, false, creatorReason);
        rules[3] = _nativeRule(4, creatorClass, keccak256("PRESS_PROOF"), creatorRecipient, false, creatorReason);
        rules[4] = _nativeRule(5, creatorClass, keccak256("GOLD"), creatorRecipient, false, creatorReason);
        rules[5] = _nativeRule(6, creatorClass, keccak256("GOLD"), creatorRecipient, false, creatorReason);
        rules[6] = _nativeRule(66, publicClass, keccak256("HELLBOUND"), address(0), true, keccak256("PUBLIC_GRAIL"));
        fixedPolicy.enabled = true;
        fixedPolicy.rules = rules;

        HellboxPublication.BirthTraitValueEnforcement[] memory marks =
            new HellboxPublication.BirthTraitValueEnforcement[](4);
        marks[0] = _nativeValue(keccak256("HELLBOUND"), 6);
        marks[1] = _nativeValue(keccak256("PRESS_PROOF"), 12);
        marks[2] = _nativeValue(keccak256("GOLD"), 18);
        marks[3] = _nativeValue(keccak256("STANDARD"), 180);

        HellboxPublication.BirthTraitValueEnforcement[] memory defects =
            new HellboxPublication.BirthTraitValueEnforcement[](5);
        defects[0] = _nativeValue(keccak256("REDACTED"), 6);
        defects[1] = _nativeValue(keccak256("CORRUPTED_PLATE"), 12);
        defects[2] = _nativeValue(keccak256("BLED_OUT"), 18);
        defects[3] = _nativeValue(keccak256("OFF_REGISTER"), 24);
        defects[4] = _nativeValue(keccak256("NONE"), 156);

        HellboxPublication.BirthTraitAxisEnforcement[] memory axes =
            new HellboxPublication.BirthTraitAxisEnforcement[](2);
        axes[0] = HellboxPublication.BirthTraitAxisEnforcement({
            axisId: keccak256("PRESS_MARK"),
            assignmentMode: keccak256("FIXED_PLUS_RANDOM_REMAINING"),
            overlapPolicy: keccak256("INDEPENDENT"),
            values: marks
        });
        axes[1] = HellboxPublication.BirthTraitAxisEnforcement({
            axisId: keccak256("PRESS_DEFECT"),
            assignmentMode: keccak256("RANDOM_REMAINING"),
            overlapPolicy: keccak256("INDEPENDENT"),
            values: defects
        });
        birthPolicy.enabled = true;
        birthPolicy.axes = axes;

        randomPolicy.enabled = true;
        randomPolicy.policyId = keccak256("HELLBOX_DRAND_FIFO_RANDOMIZATION_V1");
        randomPolicy.schemeVersion = 1;
        randomPolicy.providerConfigDigest = DRAND_PROVIDER_CONFIG_DIGEST;
        randomPolicy.copyShuffleMode = keccak256("RANDOM_NON_SEQUENTIAL");
        randomPolicy.fixedIdExclusionsDigest = _fixedDigest(fixedPolicy);
        randomPolicy.traitPoolMode = keccak256("GLOBAL_SHARED");
        randomPolicy.markDefectIndependent = true;
        randomPolicy.creatorDefectFairness = keccak256("SHARED_RANDOM");
        randomPolicy.publisherMapKnowledgePolicy = keccak256("NO_FULL_PREKNOWN_MAP");
        randomPolicy.assignmentProofMode = keccak256("DRAND_ROUND_REQUEST_EVENT_V1");
    }

    function _commitments(
        HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
        HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
        HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
    ) internal pure returns (HellboxPublication.CommitmentSet memory commitments) {
        commitments.publicationManifestDigest = keccak256("publication-manifest");
        commitments.packageDigest = keccak256("package");
        commitments.fixedCopyRulesDigest = _fixedDigest(fixedPolicy);
        commitments.birthTraitsDigest = _birthDigest(birthPolicy);
        commitments.randomizationPolicyDigest = _randomDigest(randomPolicy);
        commitments.rendererRulesDigest = keccak256("renderer-rules");
        commitments.readerPolicyDigest = keccak256("reader-policy");
        commitments.pricingPoliciesDigest = keccak256("pricing-policies");
        commitments.paymentRoutesDigest = keccak256("payment-routes");
        commitments.mintPhasesDigest = keccak256("mint-phases");
        commitments.royaltyPolicyDigest = keccak256("royalty-policy");
        commitments.treasuryPolicyDigest = keccak256("treasury-policy");
        commitments.metadataPolicyDigest = keccak256("metadata-policy");
        commitments.capabilityPolicyDigest = keccak256("capability-policy");
        commitments.protocolCompatibilityDigest = keccak256("protocol-compatibility");
        commitments.closurePolicyDigest = keccak256("closure-policy");
        commitments.authorityPolicyDigest = keccak256("authority-policy");
        commitments.eventPolicyDigest = keccak256("event-policy");
    }

    function _nativeRule(
        uint256 copyId,
        bytes32 allocationClass,
        bytes32 markCode,
        address recipient,
        bool eligible,
        bytes32 reasonCode
    ) internal pure returns (HellboxPublication.FixedCopyRuleEnforcement memory rule) {
        rule.copyId = copyId;
        rule.allocationClass = allocationClass;
        rule.requiredMarkCode = markCode;
        rule.requiredDefectCode = bytes32(0);
        rule.recipient = recipient;
        rule.publicRandomPoolEligible = eligible;
        rule.reasonCode = reasonCode;
    }

    function _nativeValue(bytes32 code, uint256 count)
        internal
        pure
        returns (HellboxPublication.BirthTraitValueEnforcement memory value)
    {
        value.code = code;
        value.count = count;
    }

    function _fixedDigest(HellboxPublication.FixedCopyRulesEnforcement memory policy) internal pure returns (bytes32) {
        return keccak256(abi.encode(keccak256("HELLBOX_ENFORCEMENT_V1:FIXED_COPY_RULES"), policy));
    }

    function _birthDigest(HellboxPublication.BirthTraitsEnforcement memory policy) internal pure returns (bytes32) {
        return keccak256(abi.encode(keccak256("HELLBOX_ENFORCEMENT_V1:BIRTH_TRAITS"), policy));
    }

    function _randomDigest(HellboxPublication.RandomizationPolicyEnforcement memory policy)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(keccak256("HELLBOX_ENFORCEMENT_V1:RANDOMIZATION_POLICY"), policy));
    }

    function _releaseDigest(
        uint256 chainId,
        address factoryAddress,
        HellboxPublication.ReleaseConfig memory config,
        HellboxPublication.CommitmentSet memory commitments
    ) internal pure returns (bytes32) {
        return keccak256(
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
}
