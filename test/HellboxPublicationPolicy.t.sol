// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";

interface PolicyVm {
    function expectPartialRevert(bytes4 revertData) external;
}

/// @notice Test-only exposure of HellboxPublication's internal Gate 4
///         enforcement-preimage hashing and verification boundary.
contract HellboxPublicationPolicyHarness is HellboxPublication {
    constructor(
        ReleaseConfig memory config,
        CommitmentSet memory commitments,
        bytes32 expectedReleaseConfigDigest,
        BirthPolicyDeploymentContext memory birthPolicyContext
    )
        HellboxPublication(
            config,
            commitments,
            expectedReleaseConfigDigest,
            birthPolicyContext
        )
    {}

    function computeFixedCopyRulesDigest(
        FixedCopyRulesEnforcement memory policy
    ) external pure returns (bytes32) {
        return _computeFixedCopyRulesDigest(policy);
    }

    function computeBirthTraitsDigest(
        BirthTraitsEnforcement memory policy
    ) external pure returns (bytes32) {
        return _computeBirthTraitsDigest(policy);
    }

    function computeRandomizationPolicyDigest(
        RandomizationPolicyEnforcement memory policy
    ) external pure returns (bytes32) {
        return _computeRandomizationPolicyDigest(policy);
    }

    function verifyEnforcementPolicyDigests(
        FixedCopyRulesEnforcement memory fixedCopyPolicy,
        BirthTraitsEnforcement memory birthTraitsPolicy,
        RandomizationPolicyEnforcement memory randomizationPolicy
    ) external view {
        _verifyEnforcementPolicyDigests(
            fixedCopyPolicy,
            birthTraitsPolicy,
            randomizationPolicy
        );
    }
}

/// @notice Gate 4 checkpoint tests for canonical deployment-time enforcement
///         preimages. These tests deliberately do not activate birth traits,
///         public minting, or a production randomness provider.
/// @dev Golden-vector hashes below were independently calculated with pinned
///      viem 2.55.19 using standard ABI tuple encoding.
contract HellboxPublicationPolicyTest {
    PolicyVm internal constant VM =
        PolicyVm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address internal constant CREATOR =
        0x1111111111111111111111111111111111111111;
    address internal constant TAIL =
        0x2222222222222222222222222222222222222222;
    address internal constant ROYALTY =
        0x3333333333333333333333333333333333333333;
    address internal constant PUBLISHER =
        0x4444444444444444444444444444444444444444;

    uint256 internal constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 internal constant CONFIG_SCHEMA_VERSION = 1;
    uint256 internal constant PUBLICATION_VERSION = 1;

    bytes32 internal constant RELEASE_CONFIG_DOMAIN =
        keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");
    bytes32 internal constant TEMPLATE_ID =
        keccak256("HELLBOX_PUBLICATION");

    bytes32 internal constant FIXED_COPY_RULES_DOMAIN =
        0xbccff8f643f5da5339d34355670c5a9387d1c6d13f3e7fbcee8044749777c57c;
    bytes32 internal constant BIRTH_TRAITS_DOMAIN =
        0x01563b27f68394f94a5183683271a142f3702405a6c722f581bfadf13d101389;
    bytes32 internal constant RANDOMIZATION_POLICY_DOMAIN =
        0x802ec9a56be49584e593de567f869a06243f426a849ce5a8f0958c50be3c690a;

    bytes32 internal constant FIXED_COPY_RULES_GOLDEN_DIGEST =
        0x3fdfc96ae2940950ec7a2ca54c107ac754be83b82257b4aebc881fe29b322ea6;
    bytes32 internal constant BIRTH_TRAITS_GOLDEN_DIGEST =
        0x26055c000fc5f3aacff1cd0a128406a16819e28abe821cf644f52b4a5c610085;
    bytes32 internal constant RANDOMIZATION_POLICY_GOLDEN_DIGEST =
        0x1da4099a93acdf89dfb385a5bec0c9783f775fa61b52e5d3222ef9631d5f3098;

    // ---------------------------------------------------------------------
    // Stable domains / immutable commitment anchors
    // ---------------------------------------------------------------------

    function testEnforcementDomainsAreVersionedAndStable() public {
        HellboxPublicationPolicyHarness publication = _deployPolicyHarness();

        require(
            publication.FIXED_COPY_RULES_ENFORCEMENT_DOMAIN() ==
                FIXED_COPY_RULES_DOMAIN,
            "fixed domain changed"
        );
        require(
            publication.BIRTH_TRAITS_ENFORCEMENT_DOMAIN() ==
                BIRTH_TRAITS_DOMAIN,
            "birth domain changed"
        );
        require(
            publication.RANDOMIZATION_POLICY_ENFORCEMENT_DOMAIN() ==
                RANDOMIZATION_POLICY_DOMAIN,
            "random domain changed"
        );
    }

    function testPolicyDigestsAreAnchoredFromCommitmentSet() public {
        HellboxPublicationPolicyHarness publication = _deployPolicyHarness();

        require(
            publication.fixedCopyRulesDigest() ==
                FIXED_COPY_RULES_GOLDEN_DIGEST,
            "fixed digest anchor"
        );
        require(
            publication.birthTraitsDigest() ==
                BIRTH_TRAITS_GOLDEN_DIGEST,
            "birth digest anchor"
        );
        require(
            publication.randomizationPolicyDigest() ==
                RANDOMIZATION_POLICY_GOLDEN_DIGEST,
            "random digest anchor"
        );
    }

    // ---------------------------------------------------------------------
    // Cross-language golden vectors
    // ---------------------------------------------------------------------

    function testFixedCopyRulesGoldenVector() public {
        HellboxPublicationPolicyHarness publication = _deployPolicyHarness();

        require(
            publication.computeFixedCopyRulesDigest(
                _fixedCopyPolicy()
            ) == FIXED_COPY_RULES_GOLDEN_DIGEST,
            "fixed policy golden vector"
        );
    }

    function testBirthTraitsGoldenVector() public {
        HellboxPublicationPolicyHarness publication = _deployPolicyHarness();

        require(
            publication.computeBirthTraitsDigest(
                _birthTraitsPolicy()
            ) == BIRTH_TRAITS_GOLDEN_DIGEST,
            "birth policy golden vector"
        );
    }

    function testRandomizationPolicyGoldenVector() public {
        HellboxPublicationPolicyHarness publication = _deployPolicyHarness();

        require(
            publication.computeRandomizationPolicyDigest(
                _randomizationPolicy()
            ) == RANDOMIZATION_POLICY_GOLDEN_DIGEST,
            "random policy golden vector"
        );
    }

    // ---------------------------------------------------------------------
    // Verification boundary
    // ---------------------------------------------------------------------

    function testMatchingEnforcementPolicyPreimagesVerify() public {
        HellboxPublicationPolicyHarness publication = _deployPolicyHarness();

        publication.verifyEnforcementPolicyDigests(
            _fixedCopyPolicy(),
            _birthTraitsPolicy(),
            _randomizationPolicy()
        );
    }

    function testFixedCopyRulesMismatchIsRejected() public {
        HellboxPublicationPolicyHarness publication = _deployPolicyHarness();

        HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy =
            _fixedCopyPolicy();
        fixedPolicy.rules[1].copyId = 67;

        VM.expectPartialRevert(
            HellboxPublication.FixedCopyRulesDigestMismatch.selector
        );

        publication.verifyEnforcementPolicyDigests(
            fixedPolicy,
            _birthTraitsPolicy(),
            _randomizationPolicy()
        );
    }

    function testBirthTraitsMismatchIsRejected() public {
        HellboxPublicationPolicyHarness publication = _deployPolicyHarness();

        HellboxPublication.BirthTraitsEnforcement memory birthPolicy =
            _birthTraitsPolicy();
        birthPolicy.axes[0].values[0].count = 7;

        VM.expectPartialRevert(
            HellboxPublication.BirthTraitsDigestMismatch.selector
        );

        publication.verifyEnforcementPolicyDigests(
            _fixedCopyPolicy(),
            birthPolicy,
            _randomizationPolicy()
        );
    }

    function testRandomizationPolicyMismatchIsRejected() public {
        HellboxPublicationPolicyHarness publication = _deployPolicyHarness();

        HellboxPublication.RandomizationPolicyEnforcement memory
            randomizationPolicy = _randomizationPolicy();
        randomizationPolicy.schemeVersion = 2;

        VM.expectPartialRevert(
            HellboxPublication.RandomizationPolicyDigestMismatch.selector
        );

        publication.verifyEnforcementPolicyDigests(
            _fixedCopyPolicy(),
            _birthTraitsPolicy(),
            randomizationPolicy
        );
    }

    // ---------------------------------------------------------------------
    // Canonical enforcement-policy fixtures
    // ---------------------------------------------------------------------

    function _fixedCopyPolicy()
        internal
        pure
        returns (
            HellboxPublication.FixedCopyRulesEnforcement memory policy
        )
    {
        HellboxPublication.FixedCopyRuleEnforcement[] memory rules =
            new HellboxPublication.FixedCopyRuleEnforcement[](2);

        rules[0] = HellboxPublication.FixedCopyRuleEnforcement({
            copyId: 1,
            allocationClass: keccak256("CREATOR_IMMEDIATE"),
            requiredMarkCode: keccak256("HELLBOUND"),
            requiredDefectCode: bytes32(0),
            recipient: CREATOR,
            publicRandomPoolEligible: false,
            reasonCode: keccak256("HARROW_IMMEDIATE")
        });

        rules[1] = HellboxPublication.FixedCopyRuleEnforcement({
            copyId: 66,
            allocationClass: keccak256("PUBLIC_RANDOM_POOL"),
            requiredMarkCode: keccak256("HELLBOUND"),
            requiredDefectCode: bytes32(0),
            recipient: address(0),
            publicRandomPoolEligible: true,
            reasonCode: keccak256("PUBLIC_GRAIL")
        });

        policy.enabled = true;
        policy.rules = rules;
    }

    function _birthTraitsPolicy()
        internal
        pure
        returns (
            HellboxPublication.BirthTraitsEnforcement memory policy
        )
    {
        HellboxPublication.BirthTraitValueEnforcement[] memory markValues =
            new HellboxPublication.BirthTraitValueEnforcement[](4);

        markValues[0] = HellboxPublication.BirthTraitValueEnforcement({
            code: keccak256("HELLBOUND"),
            count: 6
        });
        markValues[1] = HellboxPublication.BirthTraitValueEnforcement({
            code: keccak256("PRESS_PROOF"),
            count: 12
        });
        markValues[2] = HellboxPublication.BirthTraitValueEnforcement({
            code: keccak256("GOLD"),
            count: 18
        });
        markValues[3] = HellboxPublication.BirthTraitValueEnforcement({
            code: keccak256("STANDARD"),
            count: 180
        });

        HellboxPublication.BirthTraitValueEnforcement[] memory defectValues =
            new HellboxPublication.BirthTraitValueEnforcement[](5);

        defectValues[0] = HellboxPublication.BirthTraitValueEnforcement({
            code: keccak256("REDACTED"),
            count: 6
        });
        defectValues[1] = HellboxPublication.BirthTraitValueEnforcement({
            code: keccak256("CORRUPTED_PLATE"),
            count: 12
        });
        defectValues[2] = HellboxPublication.BirthTraitValueEnforcement({
            code: keccak256("BLED_OUT"),
            count: 18
        });
        defectValues[3] = HellboxPublication.BirthTraitValueEnforcement({
            code: keccak256("OFF_REGISTER"),
            count: 24
        });
        defectValues[4] = HellboxPublication.BirthTraitValueEnforcement({
            code: keccak256("NONE"),
            count: 156
        });

        HellboxPublication.BirthTraitAxisEnforcement[] memory axes =
            new HellboxPublication.BirthTraitAxisEnforcement[](2);

        axes[0] = HellboxPublication.BirthTraitAxisEnforcement({
            axisId: keccak256("PRESS_MARK"),
            assignmentMode: keccak256("FIXED_PLUS_RANDOM_REMAINING"),
            overlapPolicy: keccak256("INDEPENDENT"),
            values: markValues
        });

        axes[1] = HellboxPublication.BirthTraitAxisEnforcement({
            axisId: keccak256("PRESS_DEFECT"),
            assignmentMode: keccak256("RANDOM_REMAINING"),
            overlapPolicy: keccak256("INDEPENDENT"),
            values: defectValues
        });

        policy.enabled = true;
        policy.axes = axes;
    }

    function _randomizationPolicy()
        internal
        pure
        returns (
            HellboxPublication.RandomizationPolicyEnforcement memory policy
        )
    {
        policy.enabled = true;
        policy.policyId =
            keccak256("HELLBOX_RANDOMIZATION_TEST_V1");
        policy.schemeVersion = 1;
        policy.providerConfigDigest =
            keccak256("TEST_PROVIDER_CONFIG");
        policy.copyShuffleMode =
            keccak256("RANDOM_NON_SEQUENTIAL");
        policy.fixedIdExclusionsDigest =
            FIXED_COPY_RULES_GOLDEN_DIGEST;
        policy.traitPoolMode = keccak256("GLOBAL_SHARED");
        policy.markDefectIndependent = true;
        policy.creatorDefectFairness =
            keccak256("SHARED_RANDOM");
        policy.publisherMapKnowledgePolicy =
            keccak256("NO_FULL_PREKNOWN_MAP");
        policy.assignmentProofMode =
            keccak256("TEST_ASSIGNMENT_PROOF");
    }

    // ---------------------------------------------------------------------
    // Deployment fixtures
    // ---------------------------------------------------------------------

    function _deployPolicyHarness()
        internal
        returns (HellboxPublicationPolicyHarness publication)
    {
        HellboxPublication.ReleaseConfig memory config = _config();
        HellboxPublication.CommitmentSet memory commitments =
            _commitments();

        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(this),
            config,
            commitments
        );

        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();

        HellboxPublication.BirthPolicyDeploymentContext memory context =
            HellboxPublication.BirthPolicyDeploymentContext({
                codeStore: address(store),
                approvedCreationCodeHash:
                    keccak256(type(HellboxBirthPolicy).creationCode),
                fixedCopyPolicyPreimage: abi.encode(_fixedCopyPolicy()),
                birthTraitsPolicyPreimage: abi.encode(_birthTraitsPolicy()),
                randomizationPolicyPreimage: abi.encode(_randomizationPolicy())
            });

        publication = new HellboxPublicationPolicyHarness(
            config,
            commitments,
            expectedDigest,
            context
        );
    }

    function _config()
        internal
        pure
        returns (HellboxPublication.ReleaseConfig memory config)
    {
        config.publicationKey = "hellbox-policy-test";
        config.collectionName = "Hellbox Policy Test";
        config.collectionSymbol = "HBPT";

        config.maxSupply = 216;
        config.primaryLifetimeCap = 6;
        config.maxPerTransaction = 1;

        config.immediateCreatorRecipient = CREATOR;
        // The golden fixed-copy preimage contains exactly one creator-immediate
        // row plus the #066 public-pool row. Keep this harness binding aligned
        // so the real BirthPolicy companion validates the same golden vectors.
        config.immediateCreatorCount = 1;

        config.tailRecipient = TAIL;
        config.tailReserveCount = 3;

        config.royaltyReceiver = ROYALTY;
        config.royaltyBps = 369;

        config.publisherAuthority = PUBLISHER;

        config.readerEnabled = true;
        config.sealEnabled = true;
        config.archiveCompatible = false;
        config.dynamicMetadataEnabled = true;
        config.erc6551Compatible = false;
        config.rewardsCompatible = false;
        config.hellforgeCompatible = false;
        config.contextualTraitsEnabled = false;
    }

    function _commitments()
        internal
        pure
        returns (HellboxPublication.CommitmentSet memory commitments)
    {
        commitments.publicationManifestDigest =
            keccak256("policy-test-publication-manifest");
        commitments.packageDigest =
            keccak256("policy-test-package");

        commitments.fixedCopyRulesDigest =
            FIXED_COPY_RULES_GOLDEN_DIGEST;
        commitments.birthTraitsDigest =
            BIRTH_TRAITS_GOLDEN_DIGEST;
        commitments.randomizationPolicyDigest =
            RANDOMIZATION_POLICY_GOLDEN_DIGEST;

        commitments.rendererRulesDigest =
            keccak256("policy-test-renderer-rules");
        commitments.readerPolicyDigest =
            keccak256("policy-test-reader-policy");
        commitments.pricingPoliciesDigest =
            keccak256("policy-test-pricing-policies");
        commitments.paymentRoutesDigest =
            keccak256("policy-test-payment-routes");
        commitments.mintPhasesDigest =
            keccak256("policy-test-mint-phases");
        commitments.royaltyPolicyDigest =
            keccak256("policy-test-royalty-policy");
        commitments.treasuryPolicyDigest =
            keccak256("policy-test-treasury-policy");
        commitments.metadataPolicyDigest =
            keccak256("policy-test-metadata-policy");
        commitments.capabilityPolicyDigest =
            keccak256("policy-test-capability-policy");
        commitments.protocolCompatibilityDigest =
            keccak256("policy-test-protocol-compatibility");
        commitments.closurePolicyDigest =
            keccak256("policy-test-closure-policy");
        commitments.authorityPolicyDigest =
            keccak256("policy-test-authority-policy");
        commitments.eventPolicyDigest =
            keccak256("policy-test-event-policy");
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
