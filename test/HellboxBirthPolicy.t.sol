// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";

interface BirthPolicyVm {
    function expectPartialRevert(bytes4 revertData) external;
}

/// @notice Gate 4 V1 tests for the constructor-frozen per-publication
///         HellboxBirthPolicy companion.
/// @dev No production randomness provider or per-token trait consumption is
///      selected by this checkpoint.
contract HellboxBirthPolicyTest {
    BirthPolicyVm internal constant VM =
        BirthPolicyVm(
            address(uint160(uint256(keccak256("hevm cheat code"))))
        );

    address internal constant CREATOR =
        0x1111111111111111111111111111111111111111;

    bytes32 internal constant FIXED_DOMAIN =
        0xbccff8f643f5da5339d34355670c5a9387d1c6d13f3e7fbcee8044749777c57c;
    bytes32 internal constant BIRTH_DOMAIN =
        0x01563b27f68394f94a5183683271a142f3702405a6c722f581bfadf13d101389;
    bytes32 internal constant RANDOM_DOMAIN =
        0x802ec9a56be49584e593de567f869a06243f426a849ce5a8f0958c50be3c690a;

    bytes32 internal constant FIXED_GOLDEN =
        0x3fdfc96ae2940950ec7a2ca54c107ac754be83b82257b4aebc881fe29b322ea6;
    bytes32 internal constant BIRTH_GOLDEN =
        0x26055c000fc5f3aacff1cd0a128406a16819e28abe821cf644f52b4a5c610085;
    bytes32 internal constant RANDOM_GOLDEN =
        0x1da4099a93acdf89dfb385a5bec0c9783f775fa61b52e5d3222ef9631d5f3098;

    function testModuleIdentityAndBinding() public {
        HellboxBirthPolicy policy = _deployNative();

        require(policy.BIRTH_POLICY_VERSION() == 1, "version");
        require(
            policy.MODULE_ID() == keccak256("HELLBOX_BIRTH_POLICY"),
            "module id"
        );
        require(policy.publication() == address(this), "publication");
        require(policy.maxSupply() == 216, "supply");
        require(
            policy.immediateCreatorRecipient() == CREATOR,
            "creator"
        );
        require(policy.immediateCreatorCount() == 6, "creator count");
        require(policy.tailReserveCount() == 3, "tail");
    }

    function testDomainsAndLegacyGoldenPreimagesRemainCompatible() public {
        HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy =
            _goldenFixed();
        HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy =
            _birth();
        HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy =
            _goldenRandom();

        HellboxBirthPolicy.PublicationBinding memory binding;
        binding.maxSupply = 216;
        binding.immediateCreatorRecipient = CREATOR;
        binding.immediateCreatorCount = 1;
        binding.tailReserveCount = 0;
        binding.fixedCopyRulesDigest = FIXED_GOLDEN;
        binding.birthTraitsDigest = BIRTH_GOLDEN;
        binding.randomizationPolicyDigest = RANDOM_GOLDEN;

        HellboxBirthPolicy policy = new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );

        require(
            policy.FIXED_COPY_RULES_ENFORCEMENT_DOMAIN() == FIXED_DOMAIN,
            "fixed domain"
        );
        require(
            policy.BIRTH_TRAITS_ENFORCEMENT_DOMAIN() == BIRTH_DOMAIN,
            "birth domain"
        );
        require(
            policy.RANDOMIZATION_POLICY_ENFORCEMENT_DOMAIN() ==
                RANDOM_DOMAIN,
            "random domain"
        );
        require(policy.fixedCopyRulesDigest() == FIXED_GOLDEN, "fixed");
        require(policy.birthTraitsDigest() == BIRTH_GOLDEN, "birth");
        require(
            policy.randomizationPolicyDigest() == RANDOM_GOLDEN,
            "random"
        );
    }

    function testNativeMarkInventoryAndReservations() public {
        HellboxBirthPolicy policy = _deployNative();

        bytes32 hellbound = keccak256("HELLBOUND");
        bytes32 pressProof = keccak256("PRESS_PROOF");
        bytes32 gold = keccak256("GOLD");
        bytes32 standard = keccak256("STANDARD");

        require(policy.pressMarkEnabled(), "mark enabled");
        require(
            policy.pressMarkAssignmentMode() ==
                keccak256("FIXED_PLUS_RANDOM_REMAINING"),
            "mark mode"
        );
        require(policy.markInventoryRemainingTotal() == 216, "mark total");
        require(policy.markReservedRemainingTotal() == 7, "reserved total");

        require(policy.markInitialCount(hellbound) == 6, "hellbound");
        require(policy.markInitialCount(pressProof) == 12, "proof");
        require(policy.markInitialCount(gold) == 18, "gold");
        require(policy.markInitialCount(standard) == 180, "standard");

        require(policy.markReservedRemaining(hellbound) == 3, "hb reserve");
        require(policy.markReservedRemaining(pressProof) == 2, "pp reserve");
        require(policy.markReservedRemaining(gold) == 2, "gold reserve");
        require(policy.markReservedRemaining(standard) == 0, "std reserve");

        require(policy.markValueCodeCount() == 4, "mark codes");
        require(
            policy.randomAssignableMarkRemaining(hellbound) == 3,
            "random hb"
        );
        require(policy.randomAssignableMarkTotal() == 209, "random total");
    }

    function testNativeDefectInventoryHasNoFixedReservations() public {
        HellboxBirthPolicy policy = _deployNative();

        require(policy.pressDefectEnabled(), "defect enabled");
        require(
            policy.pressDefectAssignmentMode() ==
                keccak256("RANDOM_REMAINING"),
            "defect mode"
        );
        require(
            policy.defectInventoryRemainingTotal() == 216,
            "defect total"
        );
        require(
            policy.defectReservedRemainingTotal() == 0,
            "defect reserve"
        );
        require(
            policy.defectInitialCount(keccak256("REDACTED")) == 6,
            "redacted"
        );
        require(
            policy.defectInitialCount(keccak256("CORRUPTED_PLATE")) == 12,
            "corrupted"
        );
        require(
            policy.defectInitialCount(keccak256("BLED_OUT")) == 18,
            "bled"
        );
        require(
            policy.defectInitialCount(keccak256("OFF_REGISTER")) == 24,
            "off register"
        );
        require(
            policy.defectInitialCount(keccak256("NONE")) == 156,
            "none"
        );
        require(policy.defectValueCodeCount() == 5, "defect codes");
        require(
            policy.randomAssignableDefectTotal() == 216,
            "random defects"
        );
    }

    function testCreatorMarksAndCopy066ReservationShape() public {
        HellboxBirthPolicy policy = _deployNative();

        require(policy.fixedCopyRuleCount() == 7, "fixed count");
        require(policy.policyImmediateCopyCount() == 6, "immediate count");

        _assertCreator(policy, 1, keccak256("HELLBOUND"));
        _assertCreator(policy, 2, keccak256("HELLBOUND"));
        _assertCreator(policy, 3, keccak256("PRESS_PROOF"));
        _assertCreator(policy, 4, keccak256("PRESS_PROOF"));
        _assertCreator(policy, 5, keccak256("GOLD"));
        _assertCreator(policy, 6, keccak256("GOLD"));

        require(policy.fixedCopyRuleConfigured(66), "#066 configured");
        require(
            policy.fixedCopyAllocationClass(66) ==
                keccak256("PUBLIC_RANDOM_POOL"),
            "#066 allocation"
        );
        require(
            policy.fixedCopyRequiredMark(66) == keccak256("HELLBOUND"),
            "#066 mark"
        );
        require(
            policy.fixedCopyRequiredDefect(66) == bytes32(0),
            "#066 defect"
        );
        require(policy.fixedCopyRecipient(66) == address(0), "#066 recipient");
        require(
            policy.fixedCopyPublicRandomPoolEligible(66),
            "#066 eligible"
        );

        require(
            policy.randomAssignableMarkRemaining(
                keccak256("HELLBOUND")
            ) + 1 == 4,
            "public hellbound numerator"
        );
    }

    function testNativeRandomizationBoundaryIsStored() public {
        HellboxBirthPolicy policy = _deployNative();

        require(policy.randomizationEnabled(), "random enabled");
        require(policy.randomizationSchemeVersion() == 1, "scheme");
        require(
            policy.randomizationCopyShuffleMode() ==
                keccak256("RANDOM_NON_SEQUENTIAL"),
            "shuffle"
        );
        require(
            policy.randomizationTraitPoolMode() ==
                keccak256("GLOBAL_SHARED"),
            "pool"
        );
        require(
            policy.randomizationMarkDefectIndependent(),
            "independent"
        );
        require(
            policy.randomizationCreatorDefectFairness() ==
                keccak256("SHARED_RANDOM"),
            "creator defect"
        );
        require(
            policy.randomizationPublisherMapKnowledgePolicy() ==
                keccak256("NO_FULL_PREKNOWN_MAP"),
            "map knowledge"
        );
    }

    function testFixedDigestMismatchReverts() public {
        (
            HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy,
            HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy
        ) = _nativePolicies();

        HellboxBirthPolicy.PublicationBinding memory binding =
            _binding(fixedPolicy, birthPolicy, randomPolicy);

        binding.fixedCopyRulesDigest = keccak256("WRONG_FIXED");

        VM.expectPartialRevert(
            HellboxBirthPolicy.FixedCopyRulesDigestMismatch.selector
        );
        new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );
    }

    function testBirthDigestMismatchReverts() public {
        (
            HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy,
            HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy
        ) = _nativePolicies();

        HellboxBirthPolicy.PublicationBinding memory binding =
            _binding(fixedPolicy, birthPolicy, randomPolicy);

        binding.birthTraitsDigest = keccak256("WRONG_BIRTH");

        VM.expectPartialRevert(
            HellboxBirthPolicy.BirthTraitsDigestMismatch.selector
        );
        new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );
    }

    function testRandomizationDigestMismatchReverts() public {
        (
            HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy,
            HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy
        ) = _nativePolicies();

        HellboxBirthPolicy.PublicationBinding memory binding =
            _binding(fixedPolicy, birthPolicy, randomPolicy);

        binding.randomizationPolicyDigest = keccak256("WRONG_RANDOM");

        VM.expectPartialRevert(
            HellboxBirthPolicy.RandomizationPolicyDigestMismatch.selector
        );
        new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );
    }

    function testDuplicateFixedCopyRuleIsRejected() public {
        HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy =
            _nativeFixed();

        fixedPolicy.rules[6].copyId = 1;

        HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy =
            _birth();
        HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy =
            _random(_fixedDigest(fixedPolicy));

        HellboxBirthPolicy.PublicationBinding memory binding =
            _binding(fixedPolicy, birthPolicy, randomPolicy);

        VM.expectPartialRevert(
            HellboxBirthPolicy.DuplicateFixedCopyRule.selector
        );
        new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );
    }

    function testCreatorDefectCannotBeFixed() public {
        HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy =
            _nativeFixed();
        fixedPolicy.rules[0].requiredDefectCode = keccak256("REDACTED");

        HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy =
            _birth();
        HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy =
            _random(_fixedDigest(fixedPolicy));

        HellboxBirthPolicy.PublicationBinding memory binding =
            _binding(fixedPolicy, birthPolicy, randomPolicy);

        VM.expectPartialRevert(
            HellboxBirthPolicy.CreatorDefectMustRemainSharedRandom.selector
        );
        new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );
    }

    function testFixedMarkReservationsCannotExceedInventory() public {
        HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy =
            _nativeFixed();

        for (uint256 i = 0; i < 6; ++i) {
            fixedPolicy.rules[i].requiredMarkCode = keccak256("HELLBOUND");
        }

        HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy =
            _birth();
        HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy =
            _random(_fixedDigest(fixedPolicy));

        HellboxBirthPolicy.PublicationBinding memory binding =
            _binding(fixedPolicy, birthPolicy, randomPolicy);

        VM.expectPartialRevert(
            HellboxBirthPolicy.FixedTraitReservationExceedsInventory.selector
        );
        new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );
    }

    function testBirthInventoryMustEqualFrozenSupply() public {
        HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy =
            _nativeFixed();
        HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy =
            _birth();

        birthPolicy.axes[0].values[3].count = 179;

        HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy =
            _random(_fixedDigest(fixedPolicy));

        HellboxBirthPolicy.PublicationBinding memory binding =
            _binding(fixedPolicy, birthPolicy, randomPolicy);

        VM.expectPartialRevert(
            HellboxBirthPolicy.BirthTraitInventoryMismatch.selector
        );
        new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );
    }

    function testRandomizationRequiresGlobalSharedTraitPool() public {
        (
            HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy,
            HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy
        ) = _nativePolicies();

        randomPolicy.traitPoolMode = keccak256("INVALID_SPLIT_POOL");

        HellboxBirthPolicy.PublicationBinding memory binding =
            _binding(fixedPolicy, birthPolicy, randomPolicy);

        VM.expectPartialRevert(
            HellboxBirthPolicy.InvalidRandomizationPolicy.selector
        );
        new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );
    }

    function testCreatorRuleCountMustMatchFrozenBinding() public {
        (
            HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy,
            HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy
        ) = _nativePolicies();

        HellboxBirthPolicy.PublicationBinding memory binding =
            _binding(fixedPolicy, birthPolicy, randomPolicy);
        binding.immediateCreatorCount = 5;

        VM.expectPartialRevert(
            HellboxBirthPolicy.CreatorImmediateRuleCountMismatch.selector
        );
        new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );
    }

    function testTraitDisabledReusablePublicationShapeIsSupported() public {
        HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy;
        fixedPolicy.enabled = false;
        fixedPolicy.rules =
            new HellboxBirthPolicy.FixedCopyRuleEnforcement[](0);

        HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy;
        birthPolicy.enabled = false;
        birthPolicy.axes =
            new HellboxBirthPolicy.BirthTraitAxisEnforcement[](0);

        HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy =
            _random(_fixedDigest(fixedPolicy));

        HellboxBirthPolicy.PublicationBinding memory binding;
        binding.maxSupply = 5_555;
        binding.immediateCreatorRecipient = address(0);
        binding.immediateCreatorCount = 0;
        binding.tailReserveCount = 0;
        binding.fixedCopyRulesDigest = _fixedDigest(fixedPolicy);
        binding.birthTraitsDigest = _birthDigest(birthPolicy);
        binding.randomizationPolicyDigest = _randomDigest(randomPolicy);

        HellboxBirthPolicy policy = new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );

        require(policy.maxSupply() == 5_555, "disabled supply");
        require(policy.fixedCopyRuleCount() == 0, "disabled fixed");
        require(!policy.pressMarkEnabled(), "disabled mark");
        require(!policy.pressDefectEnabled(), "disabled defect");
        require(policy.markInventoryRemainingTotal() == 0, "disabled marks");
        require(
            policy.defectInventoryRemainingTotal() == 0,
            "disabled defects"
        );
        require(policy.randomizationEnabled(), "disabled random");
    }

    // ---------------------------------------------------------------------
    // Native policy fixtures
    // ---------------------------------------------------------------------

    function _nativePolicies()
        internal
        pure
        returns (
            HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy,
            HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy
        )
    {
        fixedPolicy = _nativeFixed();
        birthPolicy = _birth();
        randomPolicy = _random(_fixedDigest(fixedPolicy));
    }

    function _nativeFixed()
        internal
        pure
        returns (
            HellboxBirthPolicy.FixedCopyRulesEnforcement memory policy
        )
    {
        HellboxBirthPolicy.FixedCopyRuleEnforcement[] memory rules =
            new HellboxBirthPolicy.FixedCopyRuleEnforcement[](7);

        bytes32 creator = keccak256("CREATOR_IMMEDIATE");
        bytes32 publicPool = keccak256("PUBLIC_RANDOM_POOL");
        bytes32 reason = keccak256("HARROW_IMMEDIATE");

        rules[0] = _rule(
            1,
            creator,
            keccak256("HELLBOUND"),
            CREATOR,
            false,
            reason
        );
        rules[1] = _rule(
            2,
            creator,
            keccak256("HELLBOUND"),
            CREATOR,
            false,
            reason
        );
        rules[2] = _rule(
            3,
            creator,
            keccak256("PRESS_PROOF"),
            CREATOR,
            false,
            reason
        );
        rules[3] = _rule(
            4,
            creator,
            keccak256("PRESS_PROOF"),
            CREATOR,
            false,
            reason
        );
        rules[4] = _rule(
            5,
            creator,
            keccak256("GOLD"),
            CREATOR,
            false,
            reason
        );
        rules[5] = _rule(
            6,
            creator,
            keccak256("GOLD"),
            CREATOR,
            false,
            reason
        );
        rules[6] = _rule(
            66,
            publicPool,
            keccak256("HELLBOUND"),
            address(0),
            true,
            keccak256("PUBLIC_GRAIL")
        );

        policy.enabled = true;
        policy.rules = rules;
    }

    function _goldenFixed()
        internal
        pure
        returns (
            HellboxBirthPolicy.FixedCopyRulesEnforcement memory policy
        )
    {
        HellboxBirthPolicy.FixedCopyRuleEnforcement[] memory rules =
            new HellboxBirthPolicy.FixedCopyRuleEnforcement[](2);

        rules[0] = _rule(
            1,
            keccak256("CREATOR_IMMEDIATE"),
            keccak256("HELLBOUND"),
            CREATOR,
            false,
            keccak256("HARROW_IMMEDIATE")
        );
        rules[1] = _rule(
            66,
            keccak256("PUBLIC_RANDOM_POOL"),
            keccak256("HELLBOUND"),
            address(0),
            true,
            keccak256("PUBLIC_GRAIL")
        );

        policy.enabled = true;
        policy.rules = rules;
    }

    function _rule(
        uint256 copyId,
        bytes32 allocationClass,
        bytes32 markCode,
        address recipient,
        bool eligible,
        bytes32 reasonCode
    )
        internal
        pure
        returns (HellboxBirthPolicy.FixedCopyRuleEnforcement memory rule)
    {
        rule.copyId = copyId;
        rule.allocationClass = allocationClass;
        rule.requiredMarkCode = markCode;
        rule.requiredDefectCode = bytes32(0);
        rule.recipient = recipient;
        rule.publicRandomPoolEligible = eligible;
        rule.reasonCode = reasonCode;
    }

    function _birth()
        internal
        pure
        returns (
            HellboxBirthPolicy.BirthTraitsEnforcement memory policy
        )
    {
        HellboxBirthPolicy.BirthTraitValueEnforcement[] memory marks =
            new HellboxBirthPolicy.BirthTraitValueEnforcement[](4);
        marks[0] = _value(keccak256("HELLBOUND"), 6);
        marks[1] = _value(keccak256("PRESS_PROOF"), 12);
        marks[2] = _value(keccak256("GOLD"), 18);
        marks[3] = _value(keccak256("STANDARD"), 180);

        HellboxBirthPolicy.BirthTraitValueEnforcement[] memory defects =
            new HellboxBirthPolicy.BirthTraitValueEnforcement[](5);
        defects[0] = _value(keccak256("REDACTED"), 6);
        defects[1] = _value(keccak256("CORRUPTED_PLATE"), 12);
        defects[2] = _value(keccak256("BLED_OUT"), 18);
        defects[3] = _value(keccak256("OFF_REGISTER"), 24);
        defects[4] = _value(keccak256("NONE"), 156);

        HellboxBirthPolicy.BirthTraitAxisEnforcement[] memory axes =
            new HellboxBirthPolicy.BirthTraitAxisEnforcement[](2);

        axes[0] = HellboxBirthPolicy.BirthTraitAxisEnforcement({
            axisId: keccak256("PRESS_MARK"),
            assignmentMode: keccak256("FIXED_PLUS_RANDOM_REMAINING"),
            overlapPolicy: keccak256("INDEPENDENT"),
            values: marks
        });
        axes[1] = HellboxBirthPolicy.BirthTraitAxisEnforcement({
            axisId: keccak256("PRESS_DEFECT"),
            assignmentMode: keccak256("RANDOM_REMAINING"),
            overlapPolicy: keccak256("INDEPENDENT"),
            values: defects
        });

        policy.enabled = true;
        policy.axes = axes;
    }

    function _value(
        bytes32 code,
        uint256 count
    )
        internal
        pure
        returns (HellboxBirthPolicy.BirthTraitValueEnforcement memory value)
    {
        value.code = code;
        value.count = count;
    }

    function _random(
        bytes32 fixedDigest
    )
        internal
        pure
        returns (
            HellboxBirthPolicy.RandomizationPolicyEnforcement memory policy
        )
    {
        policy.enabled = true;
        policy.policyId = keccak256("HELLBOX_RANDOMIZATION_TEST_V1");
        policy.schemeVersion = 1;
        policy.providerConfigDigest = keccak256("TEST_PROVIDER_CONFIG");
        policy.copyShuffleMode = keccak256("RANDOM_NON_SEQUENTIAL");
        policy.fixedIdExclusionsDigest = fixedDigest;
        policy.traitPoolMode = keccak256("GLOBAL_SHARED");
        policy.markDefectIndependent = true;
        policy.creatorDefectFairness = keccak256("SHARED_RANDOM");
        policy.publisherMapKnowledgePolicy =
            keccak256("NO_FULL_PREKNOWN_MAP");
        policy.assignmentProofMode = keccak256("TEST_ASSIGNMENT_PROOF");
    }

    function _goldenRandom()
        internal
        pure
        returns (
            HellboxBirthPolicy.RandomizationPolicyEnforcement memory policy
        )
    {
        policy = _random(FIXED_GOLDEN);
    }

    // ---------------------------------------------------------------------
    // Deployment / digest helpers
    // ---------------------------------------------------------------------

    function _deployNative()
        internal
        returns (HellboxBirthPolicy policy)
    {
        (
            HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy,
            HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy
        ) = _nativePolicies();

        HellboxBirthPolicy.PublicationBinding memory binding =
            _binding(fixedPolicy, birthPolicy, randomPolicy);

        policy = new HellboxBirthPolicy(
            binding,
            abi.encode(fixedPolicy),
            abi.encode(birthPolicy),
            abi.encode(randomPolicy)
        );
    }

    function _binding(
        HellboxBirthPolicy.FixedCopyRulesEnforcement memory fixedPolicy,
        HellboxBirthPolicy.BirthTraitsEnforcement memory birthPolicy,
        HellboxBirthPolicy.RandomizationPolicyEnforcement memory randomPolicy
    )
        internal
        pure
        returns (HellboxBirthPolicy.PublicationBinding memory binding)
    {
        binding.maxSupply = 216;
        binding.immediateCreatorRecipient = CREATOR;
        binding.immediateCreatorCount = 6;
        binding.tailReserveCount = 3;
        binding.fixedCopyRulesDigest = _fixedDigest(fixedPolicy);
        binding.birthTraitsDigest = _birthDigest(birthPolicy);
        binding.randomizationPolicyDigest = _randomDigest(randomPolicy);
    }

    function _fixedDigest(
        HellboxBirthPolicy.FixedCopyRulesEnforcement memory policy
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(FIXED_DOMAIN, policy));
    }

    function _birthDigest(
        HellboxBirthPolicy.BirthTraitsEnforcement memory policy
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(BIRTH_DOMAIN, policy));
    }

    function _randomDigest(
        HellboxBirthPolicy.RandomizationPolicyEnforcement memory policy
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(RANDOM_DOMAIN, policy));
    }

    function _assertCreator(
        HellboxBirthPolicy policy,
        uint256 tokenId,
        bytes32 expectedMark
    ) internal view {
        require(policy.fixedCopyRuleConfigured(tokenId), "creator configured");
        require(
            policy.fixedCopyAllocationClass(tokenId) ==
                keccak256("CREATOR_IMMEDIATE"),
            "creator allocation"
        );
        require(
            policy.fixedCopyRequiredMark(tokenId) == expectedMark,
            "creator mark"
        );
        require(
            policy.fixedCopyRequiredDefect(tokenId) == bytes32(0),
            "creator defect"
        );
        require(policy.fixedCopyRecipient(tokenId) == CREATOR, "creator");
        require(
            !policy.fixedCopyPublicRandomPoolEligible(tokenId),
            "creator eligible"
        );
        require(
            policy.policyImmediateCopyAt(tokenId - 1) == tokenId,
            "creator order"
        );
    }
}
