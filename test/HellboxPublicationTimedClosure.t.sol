// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";
import {
    PrizeWalletVm,
    DeterministicEvmnetVerifierMock,
    PrizeWalletPublicationHarness,
    PrizeWalletPublicationDeployer
} from "./HellboxPrizeWalletFifoProbe.t.sol";

/// @notice Permanent Gate 4 regression coverage for native timed closure.
/// @dev Reuses only the previously reviewed Prize Wallet harness contracts;
///      it intentionally does not inherit the Prize Wallet test contract.
contract HellboxPublicationTimedClosureTest {
    PrizeWalletVm internal constant VM =
        PrizeWalletVm(
            address(
                uint160(
                    uint256(keccak256("hevm cheat code"))
                )
            )
        );

    address internal constant CREATOR =
        0x1111111111111111111111111111111111111111;
    address internal constant TAIL =
        0x2222222222222222222222222222222222222222;
    address internal constant ROYALTY =
        0x3333333333333333333333333333333333333333;
    address internal constant PUBLISHER =
        0x4444444444444444444444444444444444444444;
    address internal constant PRIZE_WALLET =
        0x7777777777777777777777777777777777777777;
    address internal constant OUTSIDER =
        0x8888888888888888888888888888888888888888;
    address internal constant ORDINARY_PRIMARY =
        0x9999999999999999999999999999999999999999;

    bytes32 internal constant RELEASE_CONFIG_DOMAIN =
        keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");
    bytes32 internal constant TEMPLATE_ID =
        keccak256("HELLBOX_PUBLICATION");
    bytes32 internal constant DRAND_PROVIDER_CONFIG_DIGEST =
        0x0d191efbb2f605bf73b6f3c4819b21bc8c7a64393c6dcfd43b6b2f6b5be401e3;

    uint256 internal constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 internal constant CONFIG_SCHEMA_VERSION = 1;
    uint256 internal constant PUBLICATION_VERSION = 1;
    uint256 internal constant START_TIMESTAMP = 1_800_000_000;

    function testTimedClosureDeadlineIsExactAndCannotQueueEarly() public {
        (
            PrizeWalletPublicationHarness publication,
            DeterministicEvmnetVerifierMock verifier
        ) = _deployPrizeReady("timed-close-deadline");

        require(
            publication.nativeMintDeadline() ==
                publication.frozenAtTimestamp() +
                    publication.NATIVE_MINT_DURATION_SECONDS(),
            "deadline derivation"
        );
        require(
            publication.NATIVE_MINT_DURATION_SECONDS() == 5_724_366,
            "native duration"
        );

        VM.warp(publication.nativeMintDeadline() - 1);
        VM.expectPartialRevert(
            HellboxPublication.NativeClosureDeadlineNotReached.selector
        );
        publication.requestNativeClosure();
        require(publication.randomnessRequestCount() == 1, "early request");

        VM.warp(publication.nativeMintDeadline());
        VM.prank(OUTSIDER);
        (uint256 requestId, uint64 round) = publication.requestNativeClosure();

        require(requestId == 2, "closure request id");
        require(round > 0, "closure round");
        require(
            verifier.roundTimestamp(round) >= block.timestamp + 12,
            "future closure round"
        );
    }

    function testTimedClosureRequestIsPermissionlessAndSingleShot() public {
        (
            PrizeWalletPublicationHarness publication,
            DeterministicEvmnetVerifierMock verifier
        ) = _deployPrizeReady("timed-close-single-shot");
        require(address(verifier) != address(0), "verifier");

        VM.warp(publication.nativeMintDeadline());
        VM.prank(OUTSIDER);
        (uint256 requestId,) = publication.requestNativeClosure();
        require(requestId == 2, "permissionless request");

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

        require(
            kind == HellboxPublication.RandomnessRequestKind.TIMED_CLOSURE,
            "closure kind"
        );
        require(storedRound != 0, "closure stored round");
        require(requestedAt == block.timestamp, "closure requested at");
        require(primaryAccount == address(0), "closure primary");
        require(recipient == TAIL, "closure recipient");
        require(!fulfilled, "closure prefulfilled");
        require(tokenId == 0, "closure token prefilled");
        require(verifiedRandomness == bytes32(0), "closure randomness prefilled");

        VM.expectPartialRevert(
            HellboxPublication.NativeClosureRequestAlreadyCreated.selector
        );
        publication.requestNativeClosure();
    }

    function testTimedClosureWrongProofRetriesSameFifoRequest() public {
        (
            PrizeWalletPublicationHarness publication,
            DeterministicEvmnetVerifierMock verifier
        ) = _deployPrizeReady("timed-close-retry");

        VM.warp(publication.nativeMintDeadline());
        (uint256 requestId, uint64 round) = publication.requestNativeClosure();
        require(requestId == 2, "closure request id");

        VM.warp(verifier.roundTimestamp(round));
        VM.expectPartialRevert(
            DeterministicEvmnetVerifierMock.MockProofRoundMismatch.selector
        );
        publication.fulfillNextRandomnessRequest(
            abi.encode(round + 1, bytes32(uint256(777)))
        );

        require(
            publication.randomnessFulfillmentCount() == 1,
            "failed proof consumed fifo"
        );
        require(!publication.tailAwarded(), "failed proof awarded tail");
        require(
            publication.candidatePoolRemaining() == 209,
            "failed proof candidate mutation"
        );

        (uint256 fulfilledRequestId,) = publication.fulfillNextRandomnessRequest(
            abi.encode(round, bytes32(uint256(777)))
        );
        require(fulfilledRequestId == requestId, "request rerolled");
        require(
            publication.randomnessFulfillmentCount() == 2,
            "retry not consumed"
        );
    }

    function testTimedClosureFinalizesThreeAndExtinguishesRemainder() public {
        (
            PrizeWalletPublicationHarness publication,
            DeterministicEvmnetVerifierMock verifier
        ) = _deployPrizeReady("timed-close-finalize");

        VM.warp(publication.nativeMintDeadline());
        (uint256 requestId, uint64 round) = publication.requestNativeClosure();
        VM.warp(verifier.roundTimestamp(round));

        (uint256 fulfilledRequestId, uint256 requestTokenId) =
            publication.fulfillNextRandomnessRequest(
                abi.encode(round, bytes32(uint256(0xC105E)))
            );

        require(fulfilledRequestId == requestId, "closure request");
        require(requestTokenId == 0, "closure request token");
        require(publication.primaryIssuanceClosed(), "primary open");
        require(!publication.trueMintOutReached(), "false mintout");
        require(publication.tailAwarded(), "tail not awarded");
        require(publication.tailAwardedCount() == 3, "tail count");
        require(publication.balanceOf(TAIL) == 3, "tail balance");
        require(publication.totalPrimaryIssued() == 10, "final primary supply");
        require(publication.candidatePoolRemaining() == 0, "candidate residue");
        require(publication.nonTailIssuanceRemaining() == 0, "non-tail residue");
        require(
            publication.extinguishedUnmintedCount() == 206,
            "extinguished count"
        );
        require(publication.closedAtTimestamp() == block.timestamp, "closed at");
        require(
            !publication.isCandidateCopyAvailable(66),
            "extinguished #066 still candidate"
        );

        HellboxBirthPolicy policy = HellboxBirthPolicy(publication.birthPolicy());
        require(policy.timedClosureInventoryFinalized(), "policy not finalized");
        require(policy.markInventoryRemainingTotal() == 0, "mark residue");
        require(policy.defectInventoryRemainingTotal() == 0, "defect residue");
        require(policy.markReservedRemainingTotal() == 0, "mark reserve residue");

        VM.expectPartialRevert(HellboxPublication.PrimaryIssuanceClosed.selector);
        publication.issueNonTailPrimaryForTest(
            ORDINARY_PRIMARY,
            ORDINARY_PRIMARY,
            123
        );
    }

    function testTimedClosureTrueMintOutFinalizesBeforeDeadlineWithoutExtinguishment()
        public
    {
        (
            PrizeWalletPublicationHarness publication,
            DeterministicEvmnetVerifierMock verifier
        ) = _deployPrizeReady("timed-close-mintout");

        for (uint256 i = 0; i < 206; ++i) {
            address account = address(uint160(0x100000 + (i / 6) + 1));
            publication.issueNonTailPrimaryForTest(
                account,
                account,
                0x1000 + i
            );
        }

        require(publication.trueMintOutReached(), "mintout not reached");
        require(publication.primaryIssuanceClosed(), "mintout not closed");
        require(publication.candidatePoolRemaining() == 3, "literal final three");
        require(block.timestamp < publication.nativeMintDeadline(), "deadline passed");

        (uint256 requestId, uint64 round) = publication.requestNativeClosure();
        require(requestId == 2, "mintout closure request");
        VM.warp(verifier.roundTimestamp(round));
        publication.fulfillNextRandomnessRequest(
            abi.encode(round, bytes32(uint256(0xF1A13)))
        );

        require(publication.tailAwarded(), "mintout tail");
        require(publication.tailAwardedCount() == 3, "mintout tail count");
        require(publication.balanceOf(TAIL) == 3, "mintout tail balance");
        require(publication.totalPrimaryIssued() == 216, "mintout supply");
        require(publication.candidatePoolRemaining() == 0, "mintout candidates");
        require(publication.extinguishedUnmintedCount() == 0, "mintout extinguish");
        require(publication.closedAtTimestamp() == block.timestamp, "mintout closed at");

        HellboxBirthPolicy policy = HellboxBirthPolicy(publication.birthPolicy());
        require(!policy.timedClosureInventoryFinalized(), "mintout used timed finalizer");
        require(policy.markInventoryRemainingTotal() == 0, "mintout mark residue");
        require(policy.defectInventoryRemainingTotal() == 0, "mintout defect residue");
    }

    function _deployPrizeReady(
        string memory publicationKey
    ) internal returns (
        PrizeWalletPublicationHarness publication,
        DeterministicEvmnetVerifierMock verifier
    ) {
        VM.warp(START_TIMESTAMP);
        verifier = new DeterministicEvmnetVerifierMock();

        PrizeWalletPublicationDeployer ignored;
        (publication, ignored) = _deployReady(
            address(verifier),
            publicationKey
        );

        (uint256 prizeRequestId, uint64 prizeRound) =
            publication.requestPrizeWalletIssuance(PRIZE_WALLET);
        require(prizeRequestId == 1, "prize request id");

        VM.warp(verifier.roundTimestamp(prizeRound));
        publication.fulfillNextRandomnessRequest(
            abi.encode(prizeRound, bytes32(uint256(0xB00757A9)))
        );

        require(publication.prizeWalletIssuanceComplete(), "prize incomplete");
        require(publication.totalPrimaryIssued() == 7, "prize total");
        require(publication.candidatePoolRemaining() == 209, "prize candidates");
        require(publication.nonTailIssuanceRemaining() == 206, "prize non-tail");
    }

    function _deployBound(
        address verifier,
        string memory publicationKey
    ) internal returns (
        PrizeWalletPublicationHarness publication,
        PrizeWalletPublicationDeployer deployer
    ) {
        deployer = new PrizeWalletPublicationDeployer(verifier);

        HellboxPublication.ReleaseConfig memory config =
            _nativeConfig(publicationKey);

        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _nativePolicies();

        HellboxPublication.CommitmentSet memory commitments =
            _commitments(fixedPolicy, birthPolicy, randomPolicy);

        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();

        HellboxPublication.BirthPolicyDeploymentContext memory context =
            HellboxPublication.BirthPolicyDeploymentContext({
                codeStore: address(store),
                approvedCreationCodeHash:
                    keccak256(type(HellboxBirthPolicy).creationCode),
                fixedCopyPolicyPreimage: abi.encode(fixedPolicy),
                birthTraitsPolicyPreimage: abi.encode(birthPolicy),
                randomizationPolicyPreimage: abi.encode(randomPolicy)
            });

        bytes32 releaseDigest = _releaseDigest(
            block.chainid,
            address(deployer),
            config,
            commitments
        );

        publication = deployer.deploy(
            config,
            commitments,
            releaseDigest,
            context
        );

        require(publication.issuanceStateInitialized(), "not initialized");
        require(
            publication.randomnessVerifier() == verifier,
            "verifier not bound"
        );
    }

    function _deployReady(
        address verifier,
        string memory publicationKey
    ) internal returns (
        PrizeWalletPublicationHarness publication,
        PrizeWalletPublicationDeployer deployer
    ) {
        (publication, deployer) = _deployBound(verifier, publicationKey);
        _issueImmediateSix(publication);
    }

    function _issueImmediateSix(
        PrizeWalletPublicationHarness publication
    ) internal {
        for (uint256 tokenId = 1; tokenId <= 6; ++tokenId) {
            publication.issueImmediateCreatorCopy(tokenId, tokenId);
        }

        require(
            publication.immediateCreatorAllocationComplete(),
            "creator allocation incomplete"
        );
        require(publication.totalPrimaryIssued() == 6, "creator total");
        require(publication.balanceOf(CREATOR) == 6, "creator balance");
        require(
            publication.candidatePoolRemaining() == 210,
            "creator candidates"
        );
        require(
            publication.nonTailIssuanceRemaining() == 207,
            "creator non-tail"
        );
    }

    function _assertPendingUntouched(
        PrizeWalletPublicationHarness publication,
        uint256 requestId,
        uint64 expectedRound
    ) internal view {
        require(publication.randomnessRequestCount() == 1, "request drift");
        require(
            publication.randomnessFulfillmentCount() == 0,
            "fulfillment drift"
        );
        require(
            publication.nextPendingRandomnessRequestId() == requestId,
            "head drift"
        );
        require(publication.totalPrimaryIssued() == 6, "mint drift");
        require(
            publication.candidatePoolRemaining() == 210,
            "candidate drift"
        );
        require(
            publication.nonTailIssuanceRemaining() == 207,
            "non-tail drift"
        );
        require(!publication.prizeWalletIssuanceComplete(), "prize drift");

        (
            ,
            uint64 round,
            ,
            ,
            address recipient,
            bool fulfilled,
            uint256 tokenId,
            bytes32 randomness
        ) = publication.randomnessRequestById(requestId);

        require(round == expectedRound, "round rerolled");
        require(recipient == PRIZE_WALLET, "recipient redirected");
        require(!fulfilled, "request consumed");
        require(tokenId == 0, "token stored");
        require(randomness == bytes32(0), "randomness stored");
    }

    function _nativeConfig(
        string memory publicationKey
    ) internal pure returns (
        HellboxPublication.ReleaseConfig memory config
    ) {
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

    function _nativePolicies() internal pure returns (
        HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
        HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
        HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
    ) {
        HellboxPublication.FixedCopyRuleEnforcement[] memory rules =
            new HellboxPublication.FixedCopyRuleEnforcement[](7);
        bytes32 creatorClass = keccak256("CREATOR_IMMEDIATE");
        bytes32 publicClass = keccak256("PUBLIC_RANDOM_POOL");
        bytes32 creatorReason = keccak256("HARROW_IMMEDIATE");

        rules[0] = _nativeRule(
            1,
            creatorClass,
            keccak256("HELLBOUND"),
            CREATOR,
            false,
            creatorReason
        );
        rules[1] = _nativeRule(
            2,
            creatorClass,
            keccak256("HELLBOUND"),
            CREATOR,
            false,
            creatorReason
        );
        rules[2] = _nativeRule(
            3,
            creatorClass,
            keccak256("PRESS_PROOF"),
            CREATOR,
            false,
            creatorReason
        );
        rules[3] = _nativeRule(
            4,
            creatorClass,
            keccak256("PRESS_PROOF"),
            CREATOR,
            false,
            creatorReason
        );
        rules[4] = _nativeRule(
            5,
            creatorClass,
            keccak256("GOLD"),
            CREATOR,
            false,
            creatorReason
        );
        rules[5] = _nativeRule(
            6,
            creatorClass,
            keccak256("GOLD"),
            CREATOR,
            false,
            creatorReason
        );
        rules[6] = _nativeRule(
            66,
            publicClass,
            keccak256("HELLBOUND"),
            address(0),
            true,
            keccak256("PUBLIC_GRAIL")
        );
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
        randomPolicy.policyId =
            keccak256("HELLBOX_DRAND_FIFO_RANDOMIZATION_V1");
        randomPolicy.schemeVersion = 1;
        randomPolicy.providerConfigDigest = DRAND_PROVIDER_CONFIG_DIGEST;
        randomPolicy.copyShuffleMode =
            keccak256("RANDOM_NON_SEQUENTIAL");
        randomPolicy.fixedIdExclusionsDigest = _fixedDigest(fixedPolicy);
        randomPolicy.traitPoolMode = keccak256("GLOBAL_SHARED");
        randomPolicy.markDefectIndependent = true;
        randomPolicy.creatorDefectFairness = keccak256("SHARED_RANDOM");
        randomPolicy.publisherMapKnowledgePolicy =
            keccak256("NO_FULL_PREKNOWN_MAP");
        randomPolicy.assignmentProofMode =
            keccak256("DRAND_ROUND_REQUEST_EVENT_V1");
    }

    function _commitments(
        HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
        HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
        HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
    ) internal pure returns (
        HellboxPublication.CommitmentSet memory commitments
    ) {
        commitments.publicationManifestDigest =
            keccak256("publication-manifest");
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
        commitments.protocolCompatibilityDigest =
            keccak256("protocol-compatibility");
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
    ) internal pure returns (
        HellboxPublication.FixedCopyRuleEnforcement memory rule
    ) {
        rule.copyId = copyId;
        rule.allocationClass = allocationClass;
        rule.requiredMarkCode = markCode;
        rule.requiredDefectCode = bytes32(0);
        rule.recipient = recipient;
        rule.publicRandomPoolEligible = eligible;
        rule.reasonCode = reasonCode;
    }

    function _nativeValue(
        bytes32 code,
        uint256 count
    ) internal pure returns (
        HellboxPublication.BirthTraitValueEnforcement memory value
    ) {
        value.code = code;
        value.count = count;
    }

    function _fixedDigest(
        HellboxPublication.FixedCopyRulesEnforcement memory policy
    ) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("HELLBOX_ENFORCEMENT_V1:FIXED_COPY_RULES"),
                policy
            )
        );
    }

    function _birthDigest(
        HellboxPublication.BirthTraitsEnforcement memory policy
    ) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("HELLBOX_ENFORCEMENT_V1:BIRTH_TRAITS"),
                policy
            )
        );
    }

    function _randomDigest(
        HellboxPublication.RandomizationPolicyEnforcement memory policy
    ) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("HELLBOX_ENFORCEMENT_V1:RANDOMIZATION_POLICY"),
                policy
            )
        );
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
