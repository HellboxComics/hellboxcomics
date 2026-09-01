// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";

interface IssuanceVm {
    function expectPartialRevert(bytes4 revertData) external;
    function prank(address msgSender) external;
}

/// @notice Test-only harness exposing HellboxPublication's deterministic
///         issuance primitives. These wrappers are not production mint/admin
///         endpoints and must never be copied into the publication surface.
contract HellboxPublicationIssuanceHarness is HellboxPublication {
    constructor(
        HellboxPublication.ReleaseConfig memory config,
        HellboxPublication.CommitmentSet memory commitments,
        bytes32 expectedReleaseConfigDigest,
        HellboxPublication.BirthPolicyDeploymentContext memory birthPolicyContext
    )
        HellboxPublication(
            config,
            commitments,
            expectedReleaseConfigDigest,
            birthPolicyContext
        )
    {}

    function initializeIssuanceState(
        uint256[] memory immediateCopyIds
    ) external {
        _initializeIssuanceState(immediateCopyIds);
    }

    function issueImmediateCreatorCopy(uint256 tokenId) external {
        _issueImmediateCreatorCopy(tokenId);
    }

    function issueNonTailPrimary(
        address primaryAccount,
        address recipient,
        uint256 entropyWord
    ) external returns (uint256 tokenId) {
        return
            _issueNonTailPrimary(
                primaryAccount,
                recipient,
                entropyWord
            );
    }

    function awardTailAfterTrueMintOut() external {
        _awardTailAfterTrueMintOut();
    }

    function burnForTest(uint256 tokenId) external {
        _burn(tokenId);
    }

    function uniformIndexForTest(
        uint256 entropyWord,
        uint256 upperBound
    ) external pure returns (uint256) {
        return _uniformIndex(entropyWord, upperBound);
    }
}

/// @notice Gate 4 deterministic issuance-state checkpoint tests.
/// @dev This suite proves only the currently implemented issuance core.
///      It deliberately does not claim completion of production entropy,
///      trait-inventory enforcement, phase/pricing policy, or early close.
contract HellboxPublicationIssuanceTest {
    IssuanceVm internal constant VM =
        IssuanceVm(
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
    address internal constant PRIMARY_A =
        0x5555555555555555555555555555555555555555;
    address internal constant PRIMARY_B =
        0x6666666666666666666666666666666666666666;
    address internal constant OTHER =
        0x7777777777777777777777777777777777777777;

    bytes32 internal constant RELEASE_CONFIG_DOMAIN =
        keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");
    bytes32 internal constant TEMPLATE_ID =
        keccak256("HELLBOX_PUBLICATION");

    uint256 internal constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 internal constant CONFIG_SCHEMA_VERSION = 1;
    uint256 internal constant PUBLICATION_VERSION = 1;

    // ---------------------------------------------------------------------
    // Standard-native initialization / immediate allocation
    // ---------------------------------------------------------------------

    function testStandardNativeInitializationStartsAt210And207() public {
        HellboxPublicationIssuanceHarness publication =
            _deployInitializedNative216();

        require(publication.issuanceStateInitialized(), "initialized");
        require(
            !publication.immediateCreatorAllocationComplete(),
            "creator should still be pending"
        );
        require(
            publication.candidatePoolRemaining() == 210,
            "candidate pool must start at 210"
        );
        require(
            publication.nonTailIssuanceRemaining() == 207,
            "non-tail must start at 207"
        );
        require(publication.totalPrimaryIssued() == 0, "issued before mint");
        require(publication.immediateCreatorIssued() == 0, "creator issued");
        require(!publication.primaryIssuanceClosed(), "closed at init");
        require(!publication.trueMintOutReached(), "mint-out at init");
        require(!publication.tailAwarded(), "tail at init");

        for (uint256 tokenId = 1; tokenId <= 6; ++tokenId) {
            require(
                publication.isImmediateCreatorCopy(tokenId),
                "immediate copy missing"
            );
            require(
                !publication.isCandidateCopyAvailable(tokenId),
                "immediate copy still candidate"
            );
        }

        require(
            publication.isCandidateCopyAvailable(66),
            "#066 must remain candidate"
        );
        require(
            publication.isCandidateCopyAvailable(216),
            "#216 must remain candidate"
        );
    }

    function testInitializationRejectsBadImmediateCopySets() public {
        HellboxPublicationIssuanceHarness publication =
            _deployUninitializedNative216();

        uint256[] memory wrongLength = new uint256[](5);
        for (uint256 i = 0; i < wrongLength.length; ++i) {
            wrongLength[i] = i + 1;
        }

        VM.expectPartialRevert(
            HellboxPublication.InvalidImmediateCreatorCopySet.selector
        );
        publication.initializeIssuanceState(wrongLength);

        uint256[] memory duplicate = _immediateCopyIds();
        duplicate[5] = 5;

        VM.expectPartialRevert(
            HellboxPublication.DuplicateImmediateCreatorCopy.selector
        );
        publication.initializeIssuanceState(duplicate);

        uint256[] memory outOfRange = _immediateCopyIds();
        outOfRange[5] = 217;

        VM.expectPartialRevert(
            HellboxPublication.InvalidCopyId.selector
        );
        publication.initializeIssuanceState(outOfRange);

        publication.initializeIssuanceState(_immediateCopyIds());

        require(publication.candidatePoolRemaining() == 210, "rollback/init");

        VM.expectPartialRevert(
            HellboxPublication.IssuanceStateAlreadyInitialized.selector
        );
        publication.initializeIssuanceState(_immediateCopyIds());
    }

    function testNormalIssuanceWaitsForAllImmediateCopies() public {
        HellboxPublicationIssuanceHarness publication =
            _deployInitializedNative216();

        for (uint256 tokenId = 1; tokenId <= 5; ++tokenId) {
            publication.issueImmediateCreatorCopy(tokenId);
        }

        require(
            publication.immediateCreatorIssued() == 5,
            "five immediate copies"
        );

        VM.expectPartialRevert(
            HellboxPublication.ImmediateCreatorAllocationIncomplete.selector
        );
        publication.issueNonTailPrimary(
            PRIMARY_A,
            PRIMARY_A,
            0
        );

        publication.issueImmediateCreatorCopy(6);

        require(
            publication.immediateCreatorAllocationComplete(),
            "creator allocation not complete"
        );

        uint256 tokenId = publication.issueNonTailPrimary(
            PRIMARY_A,
            PRIMARY_A,
            0
        );

        require(tokenId >= 7 && tokenId <= 216, "normal copy range");
    }

    function testImmediateSixMintOnlyReservedCopiesToCreator() public {
        HellboxPublicationIssuanceHarness publication =
            _deployInitializedNative216();

        VM.expectPartialRevert(
            HellboxPublication.ImmediateCreatorCopyNotReserved.selector
        );
        publication.issueImmediateCreatorCopy(7);

        uint256[6] memory issueOrder = [
            uint256(6),
            uint256(1),
            uint256(5),
            uint256(2),
            uint256(4),
            uint256(3)
        ];

        for (uint256 i = 0; i < issueOrder.length; ++i) {
            publication.issueImmediateCreatorCopy(issueOrder[i]);
        }

        require(
            publication.immediateCreatorAllocationComplete(),
            "immediate allocation"
        );
        require(publication.immediateCreatorIssued() == 6, "immediate count");
        require(publication.totalPrimaryIssued() == 6, "primary count");
        require(publication.balanceOf(CREATOR) == 6, "creator balance");
        require(
            publication.walletLifetimePrimaryUsed(CREATOR) == 0,
            "creator allocation consumed wallet cap"
        );

        require(
            publication.candidatePoolRemaining() == 210,
            "immediate mint changed candidates"
        );
        require(
            publication.nonTailIssuanceRemaining() == 207,
            "immediate mint changed non-tail"
        );

        for (uint256 tokenId = 1; tokenId <= 6; ++tokenId) {
            require(
                publication.ownerOf(tokenId) == CREATOR,
                "wrong creator owner"
            );
            require(
                publication.immediateCreatorCopyIssued(tokenId),
                "immediate issue flag"
            );
        }

        VM.expectPartialRevert(
            HellboxPublication.ImmediateCreatorAllocationAlreadyComplete.selector
        );
        publication.issueImmediateCreatorCopy(1);
    }

    // ---------------------------------------------------------------------
    // Candidate draws / lifetime accounting
    // ---------------------------------------------------------------------

    function testNormalIssuanceDecrementsBothCountersExactlyOnce() public {
        HellboxPublicationIssuanceHarness publication =
            _deployReadyNative216();

        uint256 tokenId = publication.issueNonTailPrimary(
            PRIMARY_A,
            PRIMARY_A,
            0
        );

        require(tokenId == 216, "deterministic sparse draw changed");
        require(publication.ownerOf(tokenId) == PRIMARY_A, "normal owner");
        require(
            publication.walletLifetimePrimaryUsed(PRIMARY_A) == 1,
            "wallet lifetime"
        );
        require(
            publication.candidatePoolRemaining() == 209,
            "candidate decrement"
        );
        require(
            publication.nonTailIssuanceRemaining() == 206,
            "non-tail decrement"
        );
        require(publication.totalPrimaryIssued() == 7, "total primary");
        require(
            !publication.isCandidateCopyAvailable(tokenId),
            "drawn token still candidate"
        );
        require(
            publication.isCandidateCopyAvailable(66),
            "#066 disappeared without draw"
        );
    }

    function testCopy066StaysEligibleUntilActuallyDrawn() public {
        HellboxPublicationIssuanceHarness publication =
            _deployReadyNative216();

        require(
            publication.isCandidateCopyAvailable(66),
            "#066 missing before draw"
        );

        uint256 first = publication.issueNonTailPrimary(
            PRIMARY_A,
            PRIMARY_A,
            0
        );

        require(first != 66, "#066 unexpectedly first");
        require(
            publication.isCandidateCopyAvailable(66),
            "#066 removed by unrelated draw"
        );

        uint256 second = publication.issueNonTailPrimary(
            PRIMARY_B,
            PRIMARY_B,
            65
        );

        require(second == 66, "deterministic #066 draw");
        require(
            !publication.isCandidateCopyAvailable(66),
            "#066 remained after draw"
        );
        require(publication.ownerOf(66) == PRIMARY_B, "#066 owner");
    }

    function testWalletLifetimeCapSurvivesTransferAndBurn() public {
        HellboxPublicationIssuanceHarness publication =
            _deployReadyNative216();

        uint256[6] memory tokenIds;

        for (uint256 i = 0; i < tokenIds.length; ++i) {
            tokenIds[i] = publication.issueNonTailPrimary(
                PRIMARY_A,
                PRIMARY_A,
                i
            );
        }

        require(
            publication.walletLifetimePrimaryUsed(PRIMARY_A) == 6,
            "wallet did not reach cap"
        );
        require(
            publication.candidatePoolRemaining() == 204,
            "candidate count after six"
        );
        require(
            publication.nonTailIssuanceRemaining() == 201,
            "non-tail count after six"
        );
        require(publication.totalPrimaryIssued() == 12, "issued after six");

        VM.prank(PRIMARY_A);
        publication.transferFrom(
            PRIMARY_A,
            OTHER,
            tokenIds[0]
        );

        publication.burnForTest(tokenIds[1]);

        require(
            publication.walletLifetimePrimaryUsed(PRIMARY_A) == 6,
            "transfer/burn reset lifetime use"
        );
        require(
            publication.candidatePoolRemaining() == 204,
            "transfer/burn reopened candidate capacity"
        );
        require(
            publication.nonTailIssuanceRemaining() == 201,
            "transfer/burn reopened non-tail capacity"
        );
        require(
            publication.totalPrimaryIssued() == 12,
            "burn reduced primary-issued history"
        );

        VM.expectPartialRevert(
            HellboxPublication.PrimaryLifetimeCapExceeded.selector
        );
        publication.issueNonTailPrimary(
            PRIMARY_A,
            PRIMARY_A,
            99
        );

        require(
            publication.candidatePoolRemaining() == 204,
            "failed cap check changed candidates"
        );
        require(
            publication.nonTailIssuanceRemaining() == 201,
            "failed cap check changed non-tail"
        );
    }

    function testNormalIssuanceRejectsZeroAccountsWithoutMutation() public {
        HellboxPublicationIssuanceHarness publication =
            _deployReadyNative216();

        VM.expectPartialRevert(
            HellboxPublication.InvalidPrimaryAccount.selector
        );
        publication.issueNonTailPrimary(
            address(0),
            PRIMARY_A,
            0
        );

        VM.expectPartialRevert(
            HellboxPublication.InvalidPrimaryRecipient.selector
        );
        publication.issueNonTailPrimary(
            PRIMARY_A,
            address(0),
            0
        );

        require(
            publication.candidatePoolRemaining() == 210,
            "invalid account changed candidates"
        );
        require(
            publication.nonTailIssuanceRemaining() == 207,
            "invalid account changed non-tail"
        );
        require(publication.totalPrimaryIssued() == 6, "invalid account mint");
    }

    // ---------------------------------------------------------------------
    // True mint-out / literal final-three tail
    // ---------------------------------------------------------------------

    function testTailCannotAwardBeforeTrueMintOut() public {
        HellboxPublicationIssuanceHarness publication =
            _deployReadyNative216();

        VM.expectPartialRevert(
            HellboxPublication.TailNotReady.selector
        );
        publication.awardTailAfterTrueMintOut();

        require(!publication.tailAwarded(), "premature tail flag");
        require(publication.balanceOf(TAIL) == 0, "premature tail balance");
        require(publication.candidatePoolRemaining() == 210, "tail mutation");
        require(
            publication.nonTailIssuanceRemaining() == 207,
            "tail non-tail mutation"
        );
    }

    function testTrueMintOutAwardsLiteralFinalThreeCandidatesOnce() public {
        HellboxPublicationIssuanceHarness publication =
            _deployReadyNative216();

        bool[] memory seen = new bool[](217);
        uint256 firstNormalToken;

        for (uint256 i = 0; i < 207; ++i) {
            address primaryAccount =
                address(uint160(0x1000 + (i / 6) + 1));

            uint256 tokenId = publication.issueNonTailPrimary(
                primaryAccount,
                primaryAccount,
                0
            );

            if (i == 0) {
                firstNormalToken = tokenId;
            }

            require(tokenId >= 7 && tokenId <= 216, "draw range");
            require(!seen[tokenId], "duplicate candidate draw");
            seen[tokenId] = true;
        }

        require(
            publication.candidatePoolRemaining() == 3,
            "final candidate count"
        );
        require(
            publication.nonTailIssuanceRemaining() == 0,
            "non-tail not exhausted"
        );
        require(publication.totalPrimaryIssued() == 213, "pre-tail issued");
        require(publication.trueMintOutReached(), "true mint-out missing");
        require(publication.primaryIssuanceClosed(), "mint-out not closed");
        require(!publication.tailAwarded(), "tail awarded too early");

        uint256[3] memory finalCandidates;
        uint256 found;

        for (uint256 tokenId = 7; tokenId <= 216; ++tokenId) {
            if (publication.isCandidateCopyAvailable(tokenId)) {
                require(found < 3, "too many final candidates");
                finalCandidates[found] = tokenId;
                ++found;
            }
        }

        require(found == 3, "did not find literal final three");

        publication.awardTailAfterTrueMintOut();

        require(publication.tailAwarded(), "tail flag");
        require(publication.tailAwardedCount() == 3, "tail count");
        require(publication.balanceOf(TAIL) == 3, "tail balance");
        require(publication.candidatePoolRemaining() == 0, "pool after tail");
        require(publication.totalPrimaryIssued() == 216, "final supply");

        for (uint256 i = 0; i < finalCandidates.length; ++i) {
            require(
                publication.ownerOf(finalCandidates[i]) == TAIL,
                "tail did not receive final candidate"
            );
            require(
                !publication.isCandidateCopyAvailable(
                    finalCandidates[i]
                ),
                "tail copy still candidate"
            );
        }

        VM.expectPartialRevert(
            HellboxPublication.TailAlreadyAwarded.selector
        );
        publication.awardTailAfterTrueMintOut();

        publication.burnForTest(firstNormalToken);

        require(
            publication.totalPrimaryIssued() == 216,
            "burn reopened primary history"
        );
        require(publication.primaryIssuanceClosed(), "burn reopened mint");
        require(publication.candidatePoolRemaining() == 0, "burn reopened pool");

        VM.expectPartialRevert(
            HellboxPublication.PrimaryIssuanceClosed.selector
        );
        publication.issueNonTailPrimary(
            OTHER,
            OTHER,
            123
        );
    }

    // ---------------------------------------------------------------------
    // Reuse / deterministic math boundary
    // ---------------------------------------------------------------------

    function testSciViveShapeUsesSameIssuanceCore() public {
        HellboxPublication.ReleaseConfig memory config =
            _sciViveConfig();
        HellboxPublication.CommitmentSet memory commitments =
            _commitmentsForConfig(config);

        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(this),
            config,
            commitments
        );

        HellboxPublicationIssuanceHarness publication =
            new HellboxPublicationIssuanceHarness(
                config,
                commitments,
                expectedDigest,
                _birthPolicyContext(config)
            );

        uint256[] memory noImmediateCopies = new uint256[](0);
        publication.initializeIssuanceState(noImmediateCopies);

        require(
            publication.candidatePoolRemaining() == 5_555,
            "scivive candidates"
        );
        require(
            publication.nonTailIssuanceRemaining() == 5_555,
            "scivive non-tail"
        );
        require(
            publication.immediateCreatorAllocationComplete(),
            "scivive immediate completion"
        );

        uint256 tokenId = publication.issueNonTailPrimary(
            PRIMARY_A,
            PRIMARY_A,
            0
        );

        require(tokenId >= 1 && tokenId <= 5_555, "scivive token range");
        require(publication.ownerOf(tokenId) == PRIMARY_A, "scivive owner");
        require(
            publication.walletLifetimePrimaryUsed(PRIMARY_A) == 1,
            "scivive lifetime"
        );

        VM.expectPartialRevert(
            HellboxPublication.PrimaryLifetimeCapExceeded.selector
        );
        publication.issueNonTailPrimary(
            PRIMARY_A,
            PRIMARY_A,
            1
        );

        VM.expectPartialRevert(
            HellboxPublication.TailNotConfigured.selector
        );
        publication.awardTailAfterTrueMintOut();
    }

    function testFuzzUniformIndexAlwaysStaysInsideCandidateRange(
        uint256 entropyWord,
        uint256 rawBound
    ) public {
        HellboxPublicationIssuanceHarness publication =
            _deployUninitializedNative216();

        uint256 upperBound = (rawBound % 216) + 1;
        uint256 result = publication.uniformIndexForTest(
            entropyWord,
            upperBound
        );

        require(result < upperBound, "uniform index out of range");
    }

    // ---------------------------------------------------------------------
    // Fixtures
    // ---------------------------------------------------------------------

    function _deployInitializedNative216()
        internal
        returns (HellboxPublicationIssuanceHarness publication)
    {
        publication = _deployUninitializedNative216();
        publication.initializeIssuanceState(_immediateCopyIds());
    }

    function _deployReadyNative216()
        internal
        returns (HellboxPublicationIssuanceHarness publication)
    {
        publication = _deployInitializedNative216();
        _issueImmediateSix(publication);
    }

    function _deployUninitializedNative216()
        internal
        returns (HellboxPublicationIssuanceHarness publication)
    {
        HellboxPublication.ReleaseConfig memory config =
            _native216Config();
        HellboxPublication.CommitmentSet memory commitments =
            _commitments();

        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(this),
            config,
            commitments
        );

        publication =
            new HellboxPublicationIssuanceHarness(
                config,
                commitments,
                expectedDigest,
                _birthPolicyContext(config)
            );
    }

    function _issueImmediateSix(
        HellboxPublicationIssuanceHarness publication
    ) internal {
        for (uint256 tokenId = 1; tokenId <= 6; ++tokenId) {
            publication.issueImmediateCreatorCopy(tokenId);
        }
    }

    function _immediateCopyIds()
        internal
        pure
        returns (uint256[] memory ids)
    {
        ids = new uint256[](6);

        for (uint256 i = 0; i < ids.length; ++i) {
            ids[i] = i + 1;
        }
    }

    function _baseConfig()
        internal
        pure
        returns (HellboxPublication.ReleaseConfig memory config)
    {
        config.publicationKey = "hellbox-test";
        config.collectionName = "Hellbox Test";
        config.collectionSymbol = "HBT";

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

    function _native216Config()
        internal
        pure
        returns (HellboxPublication.ReleaseConfig memory config)
    {
        config = _baseConfig();
        config.publicationKey = "hellbox-native-001";
        config.collectionName = "Hellbox Native Issue #1";
        config.collectionSymbol = "HELL001";
    }

    function _sciViveConfig()
        internal
        pure
        returns (HellboxPublication.ReleaseConfig memory config)
    {
        config = _baseConfig();

        config.publicationKey = "scivive";
        config.collectionName = "SciVive";
        config.collectionSymbol = "SCIVIVE";

        config.maxSupply = 5_555;
        config.primaryLifetimeCap = 1;
        config.maxPerTransaction = 1;

        config.immediateCreatorRecipient = address(0);
        config.immediateCreatorCount = 0;

        config.tailRecipient = address(0);
        config.tailReserveCount = 0;

        config.archiveCompatible = false;
        config.rewardsCompatible = false;
        config.hellforgeCompatible = false;
        config.contextualTraitsEnabled = false;
    }

    function _commitments()
        internal
        pure
        returns (HellboxPublication.CommitmentSet memory commitments)
    {
        return _commitmentsForConfig(_native216Config());
    }

    function _commitmentsForConfig(
        HellboxPublication.ReleaseConfig memory config
    ) internal pure returns (
        HellboxPublication.CommitmentSet memory commitments
    ) {
        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _deploymentPolicies(config);

        commitments.publicationManifestDigest =
            keccak256("publication-manifest-v1");
        commitments.packageDigest = keccak256("package-v1");
        commitments.fixedCopyRulesDigest = keccak256(
            abi.encode(
                keccak256("HELLBOX_ENFORCEMENT_V1:FIXED_COPY_RULES"),
                fixedPolicy
            )
        );
        commitments.birthTraitsDigest = keccak256(
            abi.encode(
                keccak256("HELLBOX_ENFORCEMENT_V1:BIRTH_TRAITS"),
                birthPolicy
            )
        );
        commitments.randomizationPolicyDigest = keccak256(
            abi.encode(
                keccak256("HELLBOX_ENFORCEMENT_V1:RANDOMIZATION_POLICY"),
                randomPolicy
            )
        );
        commitments.rendererRulesDigest =
            keccak256("renderer-rules-v1");
        commitments.readerPolicyDigest =
            keccak256("reader-policy-v1");
        commitments.pricingPoliciesDigest =
            keccak256("pricing-policies-v1");
        commitments.paymentRoutesDigest =
            keccak256("payment-routes-v1");
        commitments.mintPhasesDigest =
            keccak256("mint-phases-v1");
        commitments.royaltyPolicyDigest =
            keccak256("royalty-policy-v1");
        commitments.treasuryPolicyDigest =
            keccak256("treasury-policy-v1");
        commitments.metadataPolicyDigest =
            keccak256("metadata-policy-v1");
        commitments.capabilityPolicyDigest =
            keccak256("capability-policy-v1");
        commitments.protocolCompatibilityDigest =
            keccak256("protocol-compatibility-v1");
        commitments.closurePolicyDigest =
            keccak256("closure-policy-v1");
        commitments.authorityPolicyDigest =
            keccak256("authority-policy-v1");
        commitments.eventPolicyDigest =
            keccak256("event-policy-v1");
    }

    function _birthPolicyContext(
        HellboxPublication.ReleaseConfig memory config
    ) internal returns (
        HellboxPublication.BirthPolicyDeploymentContext memory context
    ) {
        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _deploymentPolicies(config);

        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();

        context.codeStore = address(store);
        context.approvedCreationCodeHash =
            keccak256(type(HellboxBirthPolicy).creationCode);
        context.fixedCopyPolicyPreimage = abi.encode(fixedPolicy);
        context.birthTraitsPolicyPreimage = abi.encode(birthPolicy);
        context.randomizationPolicyPreimage = abi.encode(randomPolicy);
    }

    function _deploymentPolicies(
        HellboxPublication.ReleaseConfig memory config
    ) internal pure returns (
        HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
        HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
        HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
    ) {
        uint256 immediateCount = config.immediateCreatorCount;
        HellboxPublication.FixedCopyRuleEnforcement[] memory rules =
            new HellboxPublication.FixedCopyRuleEnforcement[](immediateCount);

        for (uint256 i = 0; i < immediateCount; ++i) {
            rules[i] = HellboxPublication.FixedCopyRuleEnforcement({
                copyId: i + 1,
                allocationClass: keccak256("CREATOR_IMMEDIATE"),
                requiredMarkCode: bytes32(0),
                requiredDefectCode: bytes32(0),
                recipient: config.immediateCreatorRecipient,
                publicRandomPoolEligible: false,
                reasonCode: keccak256("TEST_CREATOR_IMMEDIATE")
            });
        }

        fixedPolicy.enabled = immediateCount > 0;
        fixedPolicy.rules = rules;

        birthPolicy.enabled = false;
        birthPolicy.axes =
            new HellboxPublication.BirthTraitAxisEnforcement[](0);

        bytes32 fixedDigest = keccak256(
            abi.encode(
                keccak256("HELLBOX_ENFORCEMENT_V1:FIXED_COPY_RULES"),
                fixedPolicy
            )
        );

        randomPolicy.enabled = true;
        randomPolicy.policyId = keccak256("HELLBOX_TEST_RANDOMIZATION_V1");
        randomPolicy.schemeVersion = 1;
        randomPolicy.providerConfigDigest =
            keccak256("HELLBOX_TEST_PROVIDER_CONFIG");
        randomPolicy.copyShuffleMode =
            keccak256("RANDOM_NON_SEQUENTIAL");
        randomPolicy.fixedIdExclusionsDigest = fixedDigest;
        randomPolicy.traitPoolMode = bytes32(0);
        randomPolicy.markDefectIndependent = false;
        randomPolicy.creatorDefectFairness = bytes32(0);
        randomPolicy.publisherMapKnowledgePolicy =
            keccak256("NO_FULL_PREKNOWN_MAP");
        randomPolicy.assignmentProofMode =
            keccak256("HELLBOX_TEST_ASSIGNMENT_PROOF");
    }

    function _releaseDigest(
        uint256 chainId,
        address factoryAddress,
        HellboxPublication.ReleaseConfig memory config,
        HellboxPublication.CommitmentSet memory commitments
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
}
