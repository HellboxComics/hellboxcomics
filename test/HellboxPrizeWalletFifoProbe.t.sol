// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";
import {IHellboxRandomnessVerifier} from "../contracts/interfaces/IHellboxRandomnessVerifier.sol";
import {HellboxDrandEvmnetConfig} from "../contracts/randomness/HellboxDrandEvmnetConfig.sol";
import {HellboxDrandEvmnetVerifier} from "../contracts/randomness/HellboxDrandEvmnetVerifier.sol";

interface PrizeWalletVm {
    function expectRevert() external;

    function expectPartialRevert(bytes4 revertData) external;

    function prank(address msgSender) external;

    function warp(uint256 newTimestamp) external;

    function etch(address target, bytes calldata newRuntimeBytecode) external;
}

/// @dev Test-only verifier that preserves the frozen evmnet identity/schedule
///      while accepting an ABI-encoded round/randomness pair as its proof. It is
///      used only to target exact candidate IDs and exercise rollback paths.
contract DeterministicEvmnetVerifierMock is IHellboxRandomnessVerifier {
    error MockProofLength(uint256 actual);
    error MockProofRoundMismatch(uint64 expected, uint64 actual);

    function verifierId() external pure returns (bytes32) {
        return HellboxDrandEvmnetConfig.verifierId();
    }

    function providerConfigDigest() external pure returns (bytes32) {
        return HellboxDrandEvmnetConfig.providerConfigDigest();
    }

    function firstRoundAtOrAfter(uint64 unixTimestamp) external pure returns (uint64 round) {
        return HellboxDrandEvmnetConfig.firstRoundAtOrAfter(unixTimestamp);
    }

    function roundTimestamp(uint64 round) external pure returns (uint64 unixTimestamp) {
        return HellboxDrandEvmnetConfig.roundTimestamp(round);
    }

    function verifyRound(uint64 round, bytes calldata proof) external pure returns (bytes32 randomness) {
        if (proof.length != 64) {
            revert MockProofLength(proof.length);
        }

        (uint64 suppliedRound, bytes32 suppliedRandomness) = abi.decode(proof, (uint64, bytes32));

        if (suppliedRound != round) {
            revert MockProofRoundMismatch(round, suppliedRound);
        }

        return suppliedRandomness;
    }
}

/// @dev Factory-shaped test deployer. HellboxPublication discovers and freezes
///      this immutable verifier exactly as it does for an official factory.
contract PrizeWalletPublicationDeployer {
    address public immutable randomnessVerifier;
    bytes32 public immutable randomnessVerifierRuntimeCodeHash;
    address public primarySale;
    uint256 public nativeMintDeadline;

    constructor(address verifier) {
        randomnessVerifier = verifier;
        randomnessVerifierRuntimeCodeHash = verifier.codehash;
    }

    function primarySaleByPublication(address) external view returns (address) {
        return primarySale;
    }

    function bindPrimarySaleClock(address publication, uint256 deadline) external {
        require(primarySale == address(0), "sale already bound");
        require(publication != address(0), "publication");
        primarySale = address(this);
        nativeMintDeadline = deadline;
    }

    function deploy(
        HellboxPublication.ReleaseConfig memory config,
        HellboxPublication.CommitmentSet memory commitments,
        bytes32 expectedReleaseConfigDigest,
        HellboxPublication.BirthPolicyDeploymentContext memory context
    ) external returns (PrizeWalletPublicationHarness publication) {
        publication = new PrizeWalletPublicationHarness(config, commitments, expectedReleaseConfigDigest, context);
    }
}

/// @dev Test-only wrappers around internal issuance/request primitives. None of
///      these wrappers belongs on the production publication surface.
contract PrizeWalletPublicationHarness is HellboxPublication {
    constructor(
        HellboxPublication.ReleaseConfig memory config,
        HellboxPublication.CommitmentSet memory commitments,
        bytes32 expectedReleaseConfigDigest,
        HellboxPublication.BirthPolicyDeploymentContext memory context
    ) HellboxPublication(config, commitments, expectedReleaseConfigDigest, context) {}

    function issueImmediateCreatorCopy(uint256 tokenId, uint256 entropyWord) external {
        _issueImmediateCreatorCopy(tokenId, entropyWord);
    }

    function requestPrizeWalletIssuance(address recipient) external returns (uint256 requestId, uint64 round) {
        return _requestPrizeWalletIssuance(recipient);
    }

    function issueNonTailPrimaryForTest(address primaryAccount, address recipient, uint256 entropyWord)
        external
        returns (uint256 tokenId)
    {
        return _issueNonTailPrimary(primaryAccount, recipient, entropyWord);
    }

    function uniformIndexForTest(uint256 entropyWord, uint256 upperBound) external pure returns (uint256) {
        return _uniformIndex(entropyWord, upperBound);
    }

    function candidateTokenAtForTest(uint256 candidateIndex) external view returns (uint256 tokenId) {
        return _candidateTokenAt(candidateIndex);
    }
}

contract NonReceiverPrizeTarget {}

contract HellboxPrizeWalletFifoProbeTest {
    PrizeWalletVm internal constant VM = PrizeWalletVm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address internal constant CREATOR = 0x1111111111111111111111111111111111111111;
    address internal constant TAIL = 0x2222222222222222222222222222222222222222;
    address internal constant ROYALTY = 0x3333333333333333333333333333333333333333;
    address internal constant PUBLISHER = 0x4444444444444444444444444444444444444444;
    address internal constant PRIZE_WALLET = 0x7777777777777777777777777777777777777777;
    address internal constant OUTSIDER = 0x8888888888888888888888888888888888888888;
    address internal constant ORDINARY_PRIMARY = 0x9999999999999999999999999999999999999999;

    bytes32 internal constant RELEASE_CONFIG_DOMAIN = keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");
    bytes32 internal constant TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION");
    bytes32 internal constant DRAND_PROVIDER_CONFIG_DIGEST =
        0x0d191efbb2f605bf73b6f3c4819b21bc8c7a64393c6dcfd43b6b2f6b5be401e3;
    bytes32 internal constant OBSERVED_RANDOMNESS = 0x8ccbb7b50d16a27eef4906baa2256b7fa95a3fe0db33edd988b91f070f05e2b2;

    uint64 internal constant OBSERVED_ROUND = 20_239_652;
    uint64 internal constant OBSERVED_ROUND_TIMESTAMP = 1_788_240_028;

    uint256 internal constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 internal constant CONFIG_SCHEMA_VERSION = 1;
    uint256 internal constant PUBLICATION_VERSION = 1;

    // ---------------------------------------------------------------------
    // Request ordering / recipient boundary
    // ---------------------------------------------------------------------

    function testPrizeRequestIsStrictlySeventhAndBindsFutureRound() public {
        DeterministicEvmnetVerifierMock verifier = new DeterministicEvmnetVerifierMock();
        (PrizeWalletPublicationHarness publication, PrizeWalletPublicationDeployer deployer) =
            _deployBound(address(verifier), "prize-request-order");

        VM.expectPartialRevert(HellboxPublication.ImmediateCreatorAllocationIncomplete.selector);
        publication.requestPrizeWalletIssuance(PRIZE_WALLET);

        _issueImmediateSix(publication);

        uint256 requestedAt = block.timestamp;
        (uint256 requestId, uint64 round) = publication.requestPrizeWalletIssuance(PRIZE_WALLET);

        require(requestId == 1, "request id");
        require(publication.nextPendingRandomnessRequestId() == requestId, "pending head");
        require(publication.randomnessRequestCount() == 1, "request count");
        require(publication.randomnessFulfillmentCount() == 0, "fulfillment count");
        require(publication.totalPrimaryIssued() == 6, "request minted");
        require(publication.candidatePoolRemaining() == 210, "request changed candidates");
        require(publication.nonTailIssuanceRemaining() == 207, "request changed non-tail");
        require(
            verifier.roundTimestamp(round) >= requestedAt + publication.RANDOMNESS_REQUEST_DELAY_SECONDS(),
            "round not future"
        );

        (
            HellboxPublication.RandomnessRequestKind kind,
            uint64 storedRound,
            uint64 storedRequestedAt,
            address primaryAccount,
            address recipient,
            bool fulfilled,
            uint256 tokenId,
            bytes32 verifiedRandomness
        ) = publication.randomnessRequestById(requestId);

        require(kind == HellboxPublication.RandomnessRequestKind.PRIZE_WALLET, "request kind");
        require(storedRound == round, "stored round");
        require(storedRequestedAt == uint64(requestedAt), "requested at");
        require(primaryAccount == address(0), "prize lifetime account");
        require(recipient == PRIZE_WALLET, "prize recipient");
        require(!fulfilled, "premature fulfillment");
        require(tokenId == 0, "premature token");
        require(verifiedRandomness == bytes32(0), "premature randomness");
        require(publication.prizeWalletRecipient() == PRIZE_WALLET, "recipient snapshot");
        require(publication.prizeWalletRequestId() == requestId, "request snapshot");
        require(address(deployer) == publication.factory(), "factory-shaped deployer");

        VM.expectPartialRevert(HellboxPublication.PrizeWalletRequestAlreadyCreated.selector);
        publication.requestPrizeWalletIssuance(PRIZE_WALLET);
    }

    function testPrizeRequestRejectsProjectAndContractRecipients() public {
        DeterministicEvmnetVerifierMock verifier = new DeterministicEvmnetVerifierMock();
        (PrizeWalletPublicationHarness publication, PrizeWalletPublicationDeployer deployer) =
            _deployReady(address(verifier), "prize-recipient-validation");

        address[] memory forbidden = new address[](10);
        forbidden[0] = address(0);
        forbidden[1] = address(7);
        forbidden[2] = CREATOR;
        forbidden[3] = TAIL;
        forbidden[4] = ROYALTY;
        forbidden[5] = PUBLISHER;
        forbidden[6] = address(deployer);
        forbidden[7] = address(publication);
        forbidden[8] = publication.birthPolicy();
        forbidden[9] = address(verifier);

        for (uint256 i = 0; i < forbidden.length; ++i) {
            VM.expectPartialRevert(HellboxPublication.InvalidPrizeWalletRecipient.selector);
            publication.requestPrizeWalletIssuance(forbidden[i]);
        }

        NonReceiverPrizeTarget contractRecipient = new NonReceiverPrizeTarget();

        VM.expectPartialRevert(HellboxPublication.PrizeWalletRecipientHasCode.selector);
        publication.requestPrizeWalletIssuance(address(contractRecipient));

        publication.requestPrizeWalletIssuance(PRIZE_WALLET);
        require(publication.prizeWalletRecipient() == PRIZE_WALLET, "valid EOA rejected");
    }

    function testOrdinaryNonTailCannotPrecedePrizeBootstrap() public {
        DeterministicEvmnetVerifierMock verifier = new DeterministicEvmnetVerifierMock();
        (PrizeWalletPublicationHarness publication,) = _deployReady(address(verifier), "prize-must-be-seventh");

        uint256 ordinaryTokenId = publication.issueNonTailPrimaryForTest(ORDINARY_PRIMARY, ORDINARY_PRIMARY, 123);

        require(ordinaryTokenId != 0, "ordinary issue failed");
        require(publication.totalPrimaryIssued() == 7, "ordinary seventh");

        VM.expectPartialRevert(HellboxPublication.PrizeWalletIssuanceOrderInvariant.selector);
        publication.requestPrizeWalletIssuance(PRIZE_WALLET);
    }

    // ---------------------------------------------------------------------
    // FIFO / proof / rollback behavior
    // ---------------------------------------------------------------------

    function testRoundReadinessAndWrongProofFailWithoutMutation() public {
        DeterministicEvmnetVerifierMock verifier = new DeterministicEvmnetVerifierMock();
        (PrizeWalletPublicationHarness publication,) = _deployReady(address(verifier), "prize-proof-rollback");

        (uint256 requestId, uint64 round) = publication.requestPrizeWalletIssuance(PRIZE_WALLET);
        uint64 roundTimestamp = verifier.roundTimestamp(round);

        VM.expectPartialRevert(HellboxPublication.RandomnessRoundNotReady.selector);
        publication.fulfillNextRandomnessRequest(abi.encode(round, bytes32(uint256(1))));
        _assertPendingUntouched(publication, requestId, round);

        VM.warp(roundTimestamp);

        VM.expectPartialRevert(DeterministicEvmnetVerifierMock.MockProofRoundMismatch.selector);
        publication.fulfillNextRandomnessRequest(abi.encode(round + 1, bytes32(uint256(1))));
        _assertPendingUntouched(publication, requestId, round);
    }

    function testPermissionlessRealDrandProofMintsSeventhCopy() public {
        HellboxDrandEvmnetVerifier verifier = new HellboxDrandEvmnetVerifier();
        (PrizeWalletPublicationHarness publication,) = _deployReady(address(verifier), "prize-real-drand-proof");

        VM.warp(OBSERVED_ROUND_TIMESTAMP - publication.RANDOMNESS_REQUEST_DELAY_SECONDS());

        (uint256 requestId, uint64 round) = publication.requestPrizeWalletIssuance(PRIZE_WALLET);
        require(round == OBSERVED_ROUND, "observed round mismatch");

        VM.warp(OBSERVED_ROUND_TIMESTAMP);
        VM.prank(OUTSIDER);

        (uint256 fulfilledRequestId, uint256 tokenId) = publication.fulfillNextRandomnessRequest(_observedProof());

        require(fulfilledRequestId == requestId, "fulfilled request");
        require(tokenId >= 7 && tokenId <= 216, "token range");
        require(publication.ownerOf(tokenId) == PRIZE_WALLET, "prize owner");
        require(publication.balanceOf(PRIZE_WALLET) == 1, "prize balance");
        require(publication.totalPrimaryIssued() == 7, "seventh mint");
        require(publication.candidatePoolRemaining() == 209, "post-prize candidates");
        require(publication.nonTailIssuanceRemaining() == 206, "post-prize non-tail");
        require(publication.walletLifetimePrimaryUsed(PRIZE_WALLET) == 0, "prize consumed lifetime cap");
        require(publication.prizeWalletIssuanceComplete(), "prize incomplete");
        require(publication.prizeWalletTokenId() == tokenId, "prize token");
        require(publication.nextPendingRandomnessRequestId() == 0, "queue not empty");

        (,,,,, bool fulfilled, uint256 storedTokenId, bytes32 verifiedRandomness) =
            publication.randomnessRequestById(requestId);

        require(fulfilled, "request not fulfilled");
        require(storedTokenId == tokenId, "stored token");
        require(verifiedRandomness == OBSERVED_RANDOMNESS, "stored provider randomness");

        HellboxBirthPolicy policy = HellboxBirthPolicy(publication.birthPolicy());
        require(policy.birthIdentityAssigned(tokenId), "birth unassigned");

        VM.expectPartialRevert(HellboxPublication.RandomnessRequestQueueEmpty.selector);
        publication.fulfillNextRandomnessRequest(_observedProof());
    }

    function testCopy066CanBePrizeAndIsNotHardcodedTo007() public {
        DeterministicEvmnetVerifierMock verifier = new DeterministicEvmnetVerifierMock();
        (PrizeWalletPublicationHarness publication,) = _deployReady(address(verifier), "prize-copy-066");

        (uint256 requestId, uint64 round) = publication.requestPrizeWalletIssuance(PRIZE_WALLET);

        bytes32 selectedRandomness;
        bool found;

        for (uint256 nonce = 1; nonce <= 10_000; ++nonce) {
            bytes32 candidateRandomness = bytes32(nonce);
            uint256 entropyWord = publication.deriveRandomnessRequestEntropy(requestId, candidateRandomness);
            uint256 candidateIndex = publication.uniformIndexForTest(entropyWord, 210);

            if (publication.candidateTokenAtForTest(candidateIndex) == 66) {
                selectedRandomness = candidateRandomness;
                found = true;
                break;
            }
        }

        require(found, "unable to target #066 in probe");

        VM.warp(verifier.roundTimestamp(round));
        (, uint256 tokenId) = publication.fulfillNextRandomnessRequest(abi.encode(round, selectedRandomness));

        require(tokenId == 66, "#066 not drawn");
        require(tokenId != 7, "prize hardcoded to #007");
        require(publication.ownerOf(66) == PRIZE_WALLET, "#066 owner");

        HellboxBirthPolicy policy = HellboxBirthPolicy(publication.birthPolicy());
        require(policy.birthMark(66) == keccak256("HELLBOUND"), "#066 lost fixed HELLBOUND mark");
    }

    function testRecipientMustRemainAnEoaThroughFulfillment() public {
        DeterministicEvmnetVerifierMock verifier = new DeterministicEvmnetVerifierMock();
        (PrizeWalletPublicationHarness publication,) = _deployReady(address(verifier), "prize-eoa-revalidation");

        (uint256 requestId, uint64 round) = publication.requestPrizeWalletIssuance(PRIZE_WALLET);
        bytes memory proof = abi.encode(round, bytes32(uint256(0xA11CE)));

        VM.warp(verifier.roundTimestamp(round));
        VM.etch(PRIZE_WALLET, hex"60006000fd");

        VM.expectPartialRevert(HellboxPublication.PrizeWalletRecipientHasCode.selector);
        publication.fulfillNextRandomnessRequest(proof);

        _assertPendingUntouched(publication, requestId, round);

        VM.etch(PRIZE_WALLET, hex"");
        (, uint256 tokenId) = publication.fulfillNextRandomnessRequest(proof);

        require(publication.ownerOf(tokenId) == PRIZE_WALLET, "retry owner");
        require(publication.randomnessFulfillmentCount() == 1, "retry count");
    }

    function testSameProviderWordIsDomainSeparatedAcrossPublications() public {
        DeterministicEvmnetVerifierMock verifier = new DeterministicEvmnetVerifierMock();

        (PrizeWalletPublicationHarness first,) = _deployReady(address(verifier), "prize-domain-first");
        (PrizeWalletPublicationHarness second,) = _deployReady(address(verifier), "prize-domain-second");

        (uint256 firstRequestId, uint64 firstRound) = first.requestPrizeWalletIssuance(PRIZE_WALLET);
        (uint256 secondRequestId, uint64 secondRound) = second.requestPrizeWalletIssuance(PRIZE_WALLET);

        require(firstRound == secondRound, "probe rounds differ");

        uint256 firstEntropy = first.deriveRandomnessRequestEntropy(firstRequestId, OBSERVED_RANDOMNESS);
        uint256 secondEntropy = second.deriveRandomnessRequestEntropy(secondRequestId, OBSERVED_RANDOMNESS);

        require(firstEntropy != secondEntropy, "entropy not domain separated");
    }

    // ---------------------------------------------------------------------
    // Deployment / policy helpers
    // ---------------------------------------------------------------------

    function _deployBound(address verifier, string memory publicationKey)
        internal
        returns (PrizeWalletPublicationHarness publication, PrizeWalletPublicationDeployer deployer)
    {
        deployer = new PrizeWalletPublicationDeployer(verifier);

        HellboxPublication.ReleaseConfig memory config = _nativeConfig(publicationKey);

        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _nativePolicies();

        HellboxPublication.CommitmentSet memory commitments = _commitments(fixedPolicy, birthPolicy, randomPolicy);

        HellboxBirthPolicyCodeStore store = new HellboxBirthPolicyCodeStore();

        HellboxPublication.BirthPolicyDeploymentContext memory context = HellboxPublication.BirthPolicyDeploymentContext({
            codeStore: address(store),
            approvedCreationCodeHash: keccak256(type(HellboxBirthPolicy).creationCode),
            fixedCopyPolicyPreimage: abi.encode(fixedPolicy),
            birthTraitsPolicyPreimage: abi.encode(birthPolicy),
            randomizationPolicyPreimage: abi.encode(randomPolicy)
        });

        bytes32 releaseDigest = _releaseDigest(block.chainid, address(deployer), config, commitments);

        publication = deployer.deploy(config, commitments, releaseDigest, context);
        deployer.bindPrimarySaleClock(
            address(publication), block.timestamp + publication.NATIVE_MINT_DURATION_SECONDS()
        );

        require(publication.issuanceStateInitialized(), "not initialized");
        require(publication.randomnessVerifier() == verifier, "verifier not bound");
    }

    function _deployReady(address verifier, string memory publicationKey)
        internal
        returns (PrizeWalletPublicationHarness publication, PrizeWalletPublicationDeployer deployer)
    {
        (publication, deployer) = _deployBound(verifier, publicationKey);
        _issueImmediateSix(publication);
    }

    function _issueImmediateSix(PrizeWalletPublicationHarness publication) internal {
        for (uint256 tokenId = 1; tokenId <= 6; ++tokenId) {
            publication.issueImmediateCreatorCopy(tokenId, tokenId);
        }

        require(publication.immediateCreatorAllocationComplete(), "creator allocation incomplete");
        require(publication.totalPrimaryIssued() == 6, "creator total");
        require(publication.balanceOf(CREATOR) == 6, "creator balance");
        require(publication.candidatePoolRemaining() == 210, "creator candidates");
        require(publication.nonTailIssuanceRemaining() == 207, "creator non-tail");
    }

    function _assertPendingUntouched(PrizeWalletPublicationHarness publication, uint256 requestId, uint64 expectedRound)
        internal
        view
    {
        require(publication.randomnessRequestCount() == 1, "request drift");
        require(publication.randomnessFulfillmentCount() == 0, "fulfillment drift");
        require(publication.nextPendingRandomnessRequestId() == requestId, "head drift");
        require(publication.totalPrimaryIssued() == 6, "mint drift");
        require(publication.candidatePoolRemaining() == 210, "candidate drift");
        require(publication.nonTailIssuanceRemaining() == 207, "non-tail drift");
        require(!publication.prizeWalletIssuanceComplete(), "prize drift");

        (, uint64 round,,, address recipient, bool fulfilled, uint256 tokenId, bytes32 randomness) =
            publication.randomnessRequestById(requestId);

        require(round == expectedRound, "round rerolled");
        require(recipient == PRIZE_WALLET, "recipient redirected");
        require(!fulfilled, "request consumed");
        require(tokenId == 0, "token stored");
        require(randomness == bytes32(0), "randomness stored");
    }

    function _nativeConfig(string memory publicationKey)
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

        config.immediateCreatorRecipient = CREATOR;
        config.immediateCreatorCount = 6;
        config.tailRecipient = TAIL;
        config.tailReserveCount = 3;

        config.royaltyReceiver = ROYALTY;
        config.royaltyBps = 369;
        config.publisherAuthority = PUBLISHER;

        config.readerEnabled = true;
        config.sealEnabled = true;
        config.archiveCompatible = true;
        config.dynamicMetadataEnabled = true;
        config.erc6551Compatible = true;
        config.rewardsCompatible = true;
        config.hellforgeCompatible = true;
        config.contextualTraitsEnabled = true;
    }

    function _nativePolicies()
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

        rules[0] = _nativeRule(1, creatorClass, keccak256("HELLBOUND"), CREATOR, false, creatorReason);
        rules[1] = _nativeRule(2, creatorClass, keccak256("HELLBOUND"), CREATOR, false, creatorReason);
        rules[2] = _nativeRule(3, creatorClass, keccak256("PRESS_PROOF"), CREATOR, false, creatorReason);
        rules[3] = _nativeRule(4, creatorClass, keccak256("PRESS_PROOF"), CREATOR, false, creatorReason);
        rules[4] = _nativeRule(5, creatorClass, keccak256("GOLD"), CREATOR, false, creatorReason);
        rules[5] = _nativeRule(6, creatorClass, keccak256("GOLD"), CREATOR, false, creatorReason);
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

    function _observedProof() internal pure returns (bytes memory) {
        return hex"1e8d8d4790679ad4ebf7ee4b62b022195578a21837e91ee305333b742c19e291174b857abe086f82a9fed4c04d5faafcbeab1de2d9919a7158c67fb8c89e8335";
    }
}
