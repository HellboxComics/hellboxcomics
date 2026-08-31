// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

/// @title HellboxBirthPolicy
/// @notice Gate 4 V1 non-upgradeable per-publication companion for committed
///         fixed-copy, birth-trait, and deterministic randomization policy.
/// @dev Constructor-configured only. The deploying publication is permanently
///      bound as `publication`. This checkpoint validates/stores policy
///      inventory and fixed reservations. Per-token trait consumption remains
///      deliberately deferred until the randomness assignment boundary is
///      finalized.
contract HellboxBirthPolicy {
    // ---------------------------------------------------------------------
    // Module / enforcement protocol constants
    // ---------------------------------------------------------------------

    uint256 public constant BIRTH_POLICY_VERSION = 1;
    bytes32 public constant MODULE_ID = keccak256("HELLBOX_BIRTH_POLICY");

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

    bytes32 public constant ASSIGNMENT_MODE_FIXED_PLUS_RANDOM_REMAINING =
        keccak256("FIXED_PLUS_RANDOM_REMAINING");
    bytes32 public constant ASSIGNMENT_MODE_RANDOM_REMAINING =
        keccak256("RANDOM_REMAINING");
    bytes32 public constant OVERLAP_POLICY_INDEPENDENT =
        keccak256("INDEPENDENT");

    bytes32 public constant COPY_SHUFFLE_RANDOM_NON_SEQUENTIAL =
        keccak256("RANDOM_NON_SEQUENTIAL");
    bytes32 public constant TRAIT_POOL_GLOBAL_SHARED =
        keccak256("GLOBAL_SHARED");
    bytes32 public constant CREATOR_DEFECT_SHARED_RANDOM =
        keccak256("SHARED_RANDOM");
    bytes32 public constant PUBLISHER_MAP_NO_FULL_PREKNOWN_MAP =
        keccak256("NO_FULL_PREKNOWN_MAP");

    uint256 public constant TOKEN_ID_START = 1;

    // ---------------------------------------------------------------------
    // Canonical deployment-time enforcement preimages
    // ---------------------------------------------------------------------

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

    /// @notice Narrow module binding copied from the publication's already-
    ///         validated ReleaseConfig / CommitmentSet values.
    /// @dev Module transport only; it does not modify HELLBOX_ABI_V1.
    struct PublicationBinding {
        uint256 maxSupply;
        address immediateCreatorRecipient;
        uint256 immediateCreatorCount;
        uint256 tailReserveCount;
        bytes32 fixedCopyRulesDigest;
        bytes32 birthTraitsDigest;
        bytes32 randomizationPolicyDigest;
    }

    // ---------------------------------------------------------------------
    // Permanent publication binding / frozen anchors
    // ---------------------------------------------------------------------

    address public immutable publication;

    uint256 public immutable maxSupply;
    address public immutable immediateCreatorRecipient;
    uint256 public immutable immediateCreatorCount;
    uint256 public immutable tailReserveCount;

    bytes32 public immutable fixedCopyRulesDigest;
    bytes32 public immutable birthTraitsDigest;
    bytes32 public immutable randomizationPolicyDigest;

    // ---------------------------------------------------------------------
    // Runtime-readable birth-policy state
    // ---------------------------------------------------------------------

    bool public pressMarkEnabled;
    bool public pressDefectEnabled;

    bytes32 public pressMarkAssignmentMode;
    bytes32 public pressDefectAssignmentMode;

    uint256 public markInventoryRemainingTotal;
    uint256 public defectInventoryRemainingTotal;
    uint256 public markReservedRemainingTotal;
    uint256 public defectReservedRemainingTotal;

    mapping(bytes32 code => uint256 count) public markInitialCount;
    mapping(bytes32 code => uint256 count) public markRemaining;
    mapping(bytes32 code => uint256 count) public markReservedRemaining;

    mapping(bytes32 code => uint256 count) public defectInitialCount;
    mapping(bytes32 code => uint256 count) public defectRemaining;
    mapping(bytes32 code => uint256 count) public defectReservedRemaining;

    mapping(uint256 tokenId => bool isConfigured)
        public fixedCopyRuleConfigured;
    mapping(uint256 tokenId => bytes32 allocationClass)
        public fixedCopyAllocationClass;
    mapping(uint256 tokenId => bytes32 requiredMark)
        public fixedCopyRequiredMark;
    mapping(uint256 tokenId => bytes32 requiredDefect)
        public fixedCopyRequiredDefect;
    mapping(uint256 tokenId => address recipient)
        public fixedCopyRecipient;
    mapping(uint256 tokenId => bool eligible)
        public fixedCopyPublicRandomPoolEligible;

    uint256 public immutable fixedCopyRuleCount;

    bool public randomizationEnabled;
    bytes32 public randomizationPolicyId;
    uint256 public randomizationSchemeVersion;
    bytes32 public randomizationProviderConfigDigest;
    bytes32 public randomizationCopyShuffleMode;
    bytes32 public randomizationFixedIdExclusionsDigest;
    bytes32 public randomizationTraitPoolMode;
    bool public randomizationMarkDefectIndependent;
    bytes32 public randomizationCreatorDefectFairness;
    bytes32 public randomizationPublisherMapKnowledgePolicy;
    bytes32 public randomizationAssignmentProofMode;

    bytes32[] private _markValueCodes;
    bytes32[] private _defectValueCodes;
    uint256[] private _policyImmediateCopyIds;

    // ---------------------------------------------------------------------
    // Errors
    // ---------------------------------------------------------------------

    error InvalidModuleConfiguration();
    error FixedCopyRulesDigestMismatch(bytes32 expected, bytes32 computed);
    error BirthTraitsDigestMismatch(bytes32 expected, bytes32 computed);
    error RandomizationPolicyDigestMismatch(bytes32 expected, bytes32 computed);

    error InvalidDisabledEnforcementPolicy();
    error InvalidBirthTraitAxis(bytes32 axisId);
    error DuplicateBirthTraitAxis(bytes32 axisId);
    error InvalidBirthTraitAssignmentMode(bytes32 axisId, bytes32 mode);
    error InvalidBirthTraitOverlapPolicy(bytes32 axisId, bytes32 policy);
    error InvalidBirthTraitValue(bytes32 axisId, bytes32 code, uint256 count);
    error DuplicateBirthTraitValue(bytes32 axisId, bytes32 code);
    error BirthTraitInventoryMismatch(
        bytes32 axisId,
        uint256 configured,
        uint256 supply
    );

    error InvalidCopyId(uint256 tokenId);
    error DuplicateFixedCopyRule(uint256 tokenId);
    error InvalidFixedCopyAllocationClass(
        uint256 tokenId,
        bytes32 allocationClass
    );
    error InvalidFixedCopyRecipient(uint256 tokenId, address recipient);
    error InvalidFixedCopyPoolEligibility(uint256 tokenId, bool eligible);
    error UnknownFixedBirthTrait(
        uint256 tokenId,
        bytes32 axisId,
        bytes32 code
    );
    error FixedTraitNotSupportedByAssignmentMode(
        uint256 tokenId,
        bytes32 axisId,
        bytes32 mode
    );
    error FixedTraitReservationExceedsInventory(
        uint256 tokenId,
        bytes32 axisId,
        bytes32 code,
        uint256 reserved,
        uint256 configured
    );
    error CreatorImmediateRuleCountMismatch(uint256 expected, uint256 actual);
    error CreatorDefectMustRemainSharedRandom(uint256 tokenId);
    error InvalidRandomizationPolicy();

    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------

    event BirthPolicyConfigured(
        address indexed publication,
        bytes32 indexed fixedCopyRulesDigest,
        bytes32 indexed birthTraitsDigest,
        bytes32 randomizationPolicyDigest,
        uint256 maxSupply,
        uint256 fixedCopyRuleCount,
        uint256 markInventoryTotal,
        uint256 defectInventoryTotal,
        uint256 markReservedTotal,
        uint256 defectReservedTotal
    );

    // ---------------------------------------------------------------------
    // Construction / permanent freeze
    // ---------------------------------------------------------------------

    /// @param fixedCopyPolicyPreimage ABI encoding of
    ///        FixedCopyRulesEnforcement only.
    /// @param birthTraitsPolicyPreimage ABI encoding of
    ///        BirthTraitsEnforcement only.
    /// @param randomizationPolicyPreimage ABI encoding of
    ///        RandomizationPolicyEnforcement only.
    /// @dev Each payload is narrowly decoded to its canonical struct and must
    ///      hash to the already-frozen corresponding CommitmentSet digest.
    constructor(
        PublicationBinding memory binding,
        bytes memory fixedCopyPolicyPreimage,
        bytes memory birthTraitsPolicyPreimage,
        bytes memory randomizationPolicyPreimage
    ) {
        _validateBinding(binding);

        publication = msg.sender;

        maxSupply = binding.maxSupply;
        immediateCreatorRecipient = binding.immediateCreatorRecipient;
        immediateCreatorCount = binding.immediateCreatorCount;
        tailReserveCount = binding.tailReserveCount;

        fixedCopyRulesDigest = binding.fixedCopyRulesDigest;
        birthTraitsDigest = binding.birthTraitsDigest;
        randomizationPolicyDigest = binding.randomizationPolicyDigest;

        FixedCopyRulesEnforcement memory fixedCopyPolicy = abi.decode(
            fixedCopyPolicyPreimage,
            (FixedCopyRulesEnforcement)
        );
        BirthTraitsEnforcement memory birthTraitsPolicy = abi.decode(
            birthTraitsPolicyPreimage,
            (BirthTraitsEnforcement)
        );
        RandomizationPolicyEnforcement memory randomizationPolicy = abi.decode(
            randomizationPolicyPreimage,
            (RandomizationPolicyEnforcement)
        );

        _verifyEnforcementPolicyDigests(
            fixedCopyPolicy,
            birthTraitsPolicy,
            randomizationPolicy
        );

        _loadBirthTraitPolicy(birthTraitsPolicy);
        uint256 fixedRuleCount = _loadFixedCopyPolicy(fixedCopyPolicy);
        _validateAndStoreRandomizationPolicy(randomizationPolicy);

        fixedCopyRuleCount = fixedRuleCount;

        emit BirthPolicyConfigured(
            publication,
            binding.fixedCopyRulesDigest,
            binding.birthTraitsDigest,
            binding.randomizationPolicyDigest,
            binding.maxSupply,
            fixedRuleCount,
            markInventoryRemainingTotal,
            defectInventoryRemainingTotal,
            markReservedRemainingTotal,
            defectReservedRemainingTotal
        );
    }

    // ---------------------------------------------------------------------
    // Canonical commitment verification
    // ---------------------------------------------------------------------

    function _computeFixedCopyRulesDigest(
        FixedCopyRulesEnforcement memory policy
    ) private pure returns (bytes32) {
        return keccak256(
            abi.encode(FIXED_COPY_RULES_ENFORCEMENT_DOMAIN, policy)
        );
    }

    function _computeBirthTraitsDigest(
        BirthTraitsEnforcement memory policy
    ) private pure returns (bytes32) {
        return keccak256(
            abi.encode(BIRTH_TRAITS_ENFORCEMENT_DOMAIN, policy)
        );
    }

    function _computeRandomizationPolicyDigest(
        RandomizationPolicyEnforcement memory policy
    ) private pure returns (bytes32) {
        return keccak256(
            abi.encode(
                RANDOMIZATION_POLICY_ENFORCEMENT_DOMAIN,
                policy
            )
        );
    }

    function _verifyEnforcementPolicyDigests(
        FixedCopyRulesEnforcement memory fixedCopyPolicy,
        BirthTraitsEnforcement memory birthTraitsPolicy,
        RandomizationPolicyEnforcement memory randomizationPolicy
    ) private view {
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

    // ---------------------------------------------------------------------
    // Birth-axis loading
    // ---------------------------------------------------------------------

    function _loadBirthTraitPolicy(
        BirthTraitsEnforcement memory policy
    ) private {
        if (!policy.enabled) {
            if (policy.axes.length != 0) {
                revert InvalidDisabledEnforcementPolicy();
            }
            return;
        }

        if (policy.axes.length == 0 || policy.axes.length > 2) {
            revert InvalidBirthTraitAxis(bytes32(0));
        }

        for (uint256 i = 0; i < policy.axes.length; ++i) {
            BirthTraitAxisEnforcement memory axis = policy.axes[i];

            if (axis.axisId == PRESS_MARK_AXIS_ID) {
                if (pressMarkEnabled) {
                    revert DuplicateBirthTraitAxis(axis.axisId);
                }

                pressMarkEnabled = true;
                pressMarkAssignmentMode = axis.assignmentMode;
                _loadTraitAxis(axis, true);
            } else if (axis.axisId == PRESS_DEFECT_AXIS_ID) {
                if (pressDefectEnabled) {
                    revert DuplicateBirthTraitAxis(axis.axisId);
                }

                pressDefectEnabled = true;
                pressDefectAssignmentMode = axis.assignmentMode;
                _loadTraitAxis(axis, false);
            } else {
                revert InvalidBirthTraitAxis(axis.axisId);
            }
        }
    }

    function _loadTraitAxis(
        BirthTraitAxisEnforcement memory axis,
        bool isMarkAxis
    ) private {
        if (
            axis.assignmentMode !=
            ASSIGNMENT_MODE_FIXED_PLUS_RANDOM_REMAINING &&
            axis.assignmentMode != ASSIGNMENT_MODE_RANDOM_REMAINING
        ) {
            revert InvalidBirthTraitAssignmentMode(
                axis.axisId,
                axis.assignmentMode
            );
        }

        if (axis.overlapPolicy != OVERLAP_POLICY_INDEPENDENT) {
            revert InvalidBirthTraitOverlapPolicy(
                axis.axisId,
                axis.overlapPolicy
            );
        }

        if (axis.values.length == 0) {
            revert InvalidBirthTraitValue(axis.axisId, bytes32(0), 0);
        }

        uint256 configuredTotal;

        for (uint256 i = 0; i < axis.values.length; ++i) {
            BirthTraitValueEnforcement memory value = axis.values[i];

            if (value.code == bytes32(0) || value.count == 0) {
                revert InvalidBirthTraitValue(
                    axis.axisId,
                    value.code,
                    value.count
                );
            }

            if (isMarkAxis) {
                if (markInitialCount[value.code] != 0) {
                    revert DuplicateBirthTraitValue(
                        axis.axisId,
                        value.code
                    );
                }

                markInitialCount[value.code] = value.count;
                markRemaining[value.code] = value.count;
                _markValueCodes.push(value.code);
            } else {
                if (defectInitialCount[value.code] != 0) {
                    revert DuplicateBirthTraitValue(
                        axis.axisId,
                        value.code
                    );
                }

                defectInitialCount[value.code] = value.count;
                defectRemaining[value.code] = value.count;
                _defectValueCodes.push(value.code);
            }

            configuredTotal += value.count;
        }

        if (configuredTotal != maxSupply) {
            revert BirthTraitInventoryMismatch(
                axis.axisId,
                configuredTotal,
                maxSupply
            );
        }

        if (isMarkAxis) {
            markInventoryRemainingTotal = configuredTotal;
        } else {
            defectInventoryRemainingTotal = configuredTotal;
        }
    }

    // ---------------------------------------------------------------------
    // Fixed-copy loading / trait reservations
    // ---------------------------------------------------------------------

    function _loadFixedCopyPolicy(
        FixedCopyRulesEnforcement memory policy
    ) private returns (uint256 fixedRuleCount_) {
        if (!policy.enabled) {
            if (policy.rules.length != 0 || immediateCreatorCount != 0) {
                revert InvalidDisabledEnforcementPolicy();
            }
            return 0;
        }

        uint256 creatorImmediateRuleCount;

        for (uint256 i = 0; i < policy.rules.length; ++i) {
            FixedCopyRuleEnforcement memory rule = policy.rules[i];

            _validateCopyId(rule.copyId);

            if (fixedCopyRuleConfigured[rule.copyId]) {
                revert DuplicateFixedCopyRule(rule.copyId);
            }

            if (
                rule.allocationClass ==
                ALLOCATION_CLASS_CREATOR_IMMEDIATE
            ) {
                if (rule.recipient != immediateCreatorRecipient) {
                    revert InvalidFixedCopyRecipient(
                        rule.copyId,
                        rule.recipient
                    );
                }

                if (rule.publicRandomPoolEligible) {
                    revert InvalidFixedCopyPoolEligibility(
                        rule.copyId,
                        true
                    );
                }

                _policyImmediateCopyIds.push(rule.copyId);
                ++creatorImmediateRuleCount;
            } else if (
                rule.allocationClass ==
                ALLOCATION_CLASS_PUBLIC_RANDOM_POOL
            ) {
                if (rule.recipient != address(0)) {
                    revert InvalidFixedCopyRecipient(
                        rule.copyId,
                        rule.recipient
                    );
                }

                if (!rule.publicRandomPoolEligible) {
                    revert InvalidFixedCopyPoolEligibility(
                        rule.copyId,
                        false
                    );
                }
            } else {
                revert InvalidFixedCopyAllocationClass(
                    rule.copyId,
                    rule.allocationClass
                );
            }

            if (rule.requiredMarkCode != bytes32(0)) {
                _reserveFixedTrait(
                    rule.copyId,
                    PRESS_MARK_AXIS_ID,
                    rule.requiredMarkCode,
                    pressMarkAssignmentMode
                );
            }

            if (rule.requiredDefectCode != bytes32(0)) {
                if (
                    rule.allocationClass ==
                    ALLOCATION_CLASS_CREATOR_IMMEDIATE
                ) {
                    revert CreatorDefectMustRemainSharedRandom(
                        rule.copyId
                    );
                }

                _reserveFixedTrait(
                    rule.copyId,
                    PRESS_DEFECT_AXIS_ID,
                    rule.requiredDefectCode,
                    pressDefectAssignmentMode
                );
            }

            fixedCopyRuleConfigured[rule.copyId] = true;
            fixedCopyAllocationClass[rule.copyId] =
                rule.allocationClass;
            fixedCopyRequiredMark[rule.copyId] =
                rule.requiredMarkCode;
            fixedCopyRequiredDefect[rule.copyId] =
                rule.requiredDefectCode;
            fixedCopyRecipient[rule.copyId] = rule.recipient;
            fixedCopyPublicRandomPoolEligible[rule.copyId] =
                rule.publicRandomPoolEligible;

            ++fixedRuleCount_;
        }

        if (creatorImmediateRuleCount != immediateCreatorCount) {
            revert CreatorImmediateRuleCountMismatch(
                immediateCreatorCount,
                creatorImmediateRuleCount
            );
        }
    }

    function _reserveFixedTrait(
        uint256 tokenId,
        bytes32 axisId,
        bytes32 code,
        bytes32 assignmentMode
    ) private {
        if (
            assignmentMode !=
            ASSIGNMENT_MODE_FIXED_PLUS_RANDOM_REMAINING
        ) {
            revert FixedTraitNotSupportedByAssignmentMode(
                tokenId,
                axisId,
                assignmentMode
            );
        }

        if (axisId == PRESS_MARK_AXIS_ID) {
            uint256 configuredCount = markInitialCount[code];

            if (!pressMarkEnabled || configuredCount == 0) {
                revert UnknownFixedBirthTrait(
                    tokenId,
                    axisId,
                    code
                );
            }

            uint256 reservedCount = markReservedRemaining[code] + 1;

            if (reservedCount > configuredCount) {
                revert FixedTraitReservationExceedsInventory(
                    tokenId,
                    axisId,
                    code,
                    reservedCount,
                    configuredCount
                );
            }

            markReservedRemaining[code] = reservedCount;
            ++markReservedRemainingTotal;
        } else if (axisId == PRESS_DEFECT_AXIS_ID) {
            uint256 configuredCount = defectInitialCount[code];

            if (!pressDefectEnabled || configuredCount == 0) {
                revert UnknownFixedBirthTrait(
                    tokenId,
                    axisId,
                    code
                );
            }

            uint256 reservedCount =
                defectReservedRemaining[code] + 1;

            if (reservedCount > configuredCount) {
                revert FixedTraitReservationExceedsInventory(
                    tokenId,
                    axisId,
                    code,
                    reservedCount,
                    configuredCount
                );
            }

            defectReservedRemaining[code] = reservedCount;
            ++defectReservedRemainingTotal;
        } else {
            revert InvalidBirthTraitAxis(axisId);
        }
    }

    // ---------------------------------------------------------------------
    // Randomization boundary validation / storage
    // ---------------------------------------------------------------------

    function _validateAndStoreRandomizationPolicy(
        RandomizationPolicyEnforcement memory policy
    ) private {
        uint256 nonTailCapacity =
            maxSupply -
            immediateCreatorCount -
            tailReserveCount;

        if (nonTailCapacity > 0 && !policy.enabled) {
            revert InvalidRandomizationPolicy();
        }

        if (!policy.enabled) {
            return;
        }

        if (
            policy.policyId == bytes32(0) ||
            policy.schemeVersion == 0 ||
            policy.providerConfigDigest == bytes32(0) ||
            policy.copyShuffleMode !=
            COPY_SHUFFLE_RANDOM_NON_SEQUENTIAL ||
            policy.fixedIdExclusionsDigest !=
            fixedCopyRulesDigest ||
            policy.publisherMapKnowledgePolicy !=
            PUBLISHER_MAP_NO_FULL_PREKNOWN_MAP ||
            policy.assignmentProofMode == bytes32(0)
        ) {
            revert InvalidRandomizationPolicy();
        }

        if (
            (pressMarkEnabled || pressDefectEnabled) &&
            policy.traitPoolMode != TRAIT_POOL_GLOBAL_SHARED
        ) {
            revert InvalidRandomizationPolicy();
        }

        if (
            pressMarkEnabled &&
            pressDefectEnabled &&
            !policy.markDefectIndependent
        ) {
            revert InvalidRandomizationPolicy();
        }

        if (
            pressDefectEnabled &&
            immediateCreatorCount > 0 &&
            policy.creatorDefectFairness !=
            CREATOR_DEFECT_SHARED_RANDOM
        ) {
            revert InvalidRandomizationPolicy();
        }

        randomizationEnabled = policy.enabled;
        randomizationPolicyId = policy.policyId;
        randomizationSchemeVersion = policy.schemeVersion;
        randomizationProviderConfigDigest = policy.providerConfigDigest;
        randomizationCopyShuffleMode = policy.copyShuffleMode;
        randomizationFixedIdExclusionsDigest =
            policy.fixedIdExclusionsDigest;
        randomizationTraitPoolMode = policy.traitPoolMode;
        randomizationMarkDefectIndependent =
            policy.markDefectIndependent;
        randomizationCreatorDefectFairness =
            policy.creatorDefectFairness;
        randomizationPublisherMapKnowledgePolicy =
            policy.publisherMapKnowledgePolicy;
        randomizationAssignmentProofMode =
            policy.assignmentProofMode;
    }

    // ---------------------------------------------------------------------
    // Read-only policy / inventory surfaces
    // ---------------------------------------------------------------------

    function markValueCodeCount() external view returns (uint256) {
        return _markValueCodes.length;
    }

    function markValueCodeAt(uint256 index) external view returns (bytes32) {
        return _markValueCodes[index];
    }

    function defectValueCodeCount() external view returns (uint256) {
        return _defectValueCodes.length;
    }

    function defectValueCodeAt(uint256 index) external view returns (bytes32) {
        return _defectValueCodes[index];
    }

    function policyImmediateCopyCount() external view returns (uint256) {
        return _policyImmediateCopyIds.length;
    }

    function policyImmediateCopyAt(uint256 index) external view returns (uint256) {
        return _policyImmediateCopyIds[index];
    }

    function randomAssignableMarkRemaining(
        bytes32 code
    ) external view returns (uint256) {
        return markRemaining[code] - markReservedRemaining[code];
    }

    function randomAssignableDefectRemaining(
        bytes32 code
    ) external view returns (uint256) {
        return defectRemaining[code] - defectReservedRemaining[code];
    }

    function randomAssignableMarkTotal() external view returns (uint256) {
        return
            markInventoryRemainingTotal -
            markReservedRemainingTotal;
    }

    function randomAssignableDefectTotal() external view returns (uint256) {
        return
            defectInventoryRemainingTotal -
            defectReservedRemainingTotal;
    }

    // ---------------------------------------------------------------------
    // Internal helpers
    // ---------------------------------------------------------------------

    function _validateBinding(
        PublicationBinding memory binding
    ) private pure {
        if (
            binding.maxSupply == 0 ||
            binding.immediateCreatorCount > binding.maxSupply ||
            binding.tailReserveCount > binding.maxSupply ||
            binding.immediateCreatorCount + binding.tailReserveCount >
            binding.maxSupply ||
            (
                binding.immediateCreatorCount > 0 &&
                binding.immediateCreatorRecipient == address(0)
            ) ||
            (
                binding.immediateCreatorCount == 0 &&
                binding.immediateCreatorRecipient != address(0)
            )
        ) {
            revert InvalidModuleConfiguration();
        }
    }

    function _validateCopyId(uint256 tokenId) private view {
        if (tokenId < TOKEN_ID_START || tokenId > maxSupply) {
            revert InvalidCopyId(tokenId);
        }
    }
}
