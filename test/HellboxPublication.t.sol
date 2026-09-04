// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";

interface Vm {
    function expectPartialRevert(bytes4 revertData) external;
}

/// @notice Gate 4 checkpoint tests for the frozen HellboxPublication V1 kernel.
/// @dev Deliberately avoids a test-framework dependency so the publication kernel
///      can be validated with the smallest possible dependency surface.
contract HellboxPublicationTest {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    address internal constant CREATOR = 0x1111111111111111111111111111111111111111;
    address internal constant TAIL = 0x2222222222222222222222222222222222222222;
    address internal constant ROYALTY = 0x3333333333333333333333333333333333333333;
    address internal constant PUBLISHER = 0x4444444444444444444444444444444444444444;

    bytes32 internal constant RELEASE_CONFIG_DOMAIN = keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");
    bytes32 internal constant TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION");

    uint256 internal constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 internal constant CONFIG_SCHEMA_VERSION = 1;
    uint256 internal constant PUBLICATION_VERSION = 1;

    // ---------------------------------------------------------------------
    // Successful deployment / freeze checks
    // ---------------------------------------------------------------------

    function testNative216ShapeFreezesExpectedConfiguration() public {
        HellboxPublication.ReleaseConfig memory config = _native216Config();
        HellboxPublication.CommitmentSet memory commitments = _commitments();

        bytes32 expectedDigest = _releaseDigest(block.chainid, address(this), config, commitments);

        HellboxPublication publication =
            new HellboxPublication(config, commitments, expectedDigest, _birthPolicyContext(config));

        require(
            keccak256(bytes(publication.publicationKey())) == keccak256(bytes("hellbox-native-001")), "publication key"
        );
        require(keccak256(bytes(publication.name())) == keccak256(bytes("Hellbox Native Issue #1")), "collection name");
        require(keccak256(bytes(publication.symbol())) == keccak256(bytes("HELL001")), "collection symbol");

        require(publication.releaseChainId() == block.chainid, "chain id");
        require(publication.factory() == address(this), "factory");

        address policyAddress = publication.birthPolicy();
        require(policyAddress != address(0), "birth policy");
        require(policyAddress.code.length > 0, "birth policy code");
        require(HellboxBirthPolicy(policyAddress).publication() == address(publication), "birth policy publication");

        require(publication.maxSupply() == 216, "max supply");
        require(publication.primaryLifetimeCap() == 6, "wallet cap");
        require(publication.maxPerTransaction() == 1, "one per tx");

        require(publication.immediateCreatorRecipient() == CREATOR, "creator recipient");
        require(publication.immediateCreatorCount() == 6, "creator count");
        require(publication.tailRecipient() == TAIL, "tail recipient");
        require(publication.tailReserveCount() == 3, "tail count");

        require(publication.royaltyReceiver() == ROYALTY, "royalty receiver");
        require(publication.royaltyBps() == 369, "royalty bps");
        require(publication.publisherAuthority() == PUBLISHER, "publisher authority");

        require(publication.readerEnabled(), "reader");
        require(publication.sealEnabled(), "seal");
        require(publication.archiveCompatible(), "archive");
        require(publication.dynamicMetadataEnabled(), "dynamic metadata");
        require(publication.erc6551Compatible(), "erc6551");
        require(publication.rewardsCompatible(), "rewards");
        require(publication.hellforgeCompatible(), "hellforge");
        require(publication.contextualTraitsEnabled(), "contextual traits");

        require(publication.publicationManifestDigest() == commitments.publicationManifestDigest, "manifest digest");
        require(publication.packageDigest() == commitments.packageDigest, "package digest");
        require(publication.commitmentsDigest() == _commitmentsDigest(commitments), "commitments digest");
        require(publication.releaseConfigDigest() == expectedDigest, "release digest");

        require(publication.configFrozen(), "config frozen");
        require(publication.frozenAtBlock() == block.number, "freeze block");
        require(publication.frozenAtTimestamp() == block.timestamp, "freeze timestamp");
    }

    function testSciViveShapeIsAccepted() public {
        HellboxPublication.ReleaseConfig memory config = _baseConfig();

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

        config.readerEnabled = true;
        config.sealEnabled = true;
        config.archiveCompatible = false;
        config.dynamicMetadataEnabled = true;
        config.erc6551Compatible = true;
        config.rewardsCompatible = false;
        config.hellforgeCompatible = false;
        config.contextualTraitsEnabled = false;

        HellboxPublication.CommitmentSet memory commitments = _commitmentsForConfig(config);

        bytes32 expectedDigest = _releaseDigest(block.chainid, address(this), config, commitments);

        HellboxPublication.BirthPolicyDeploymentContext memory context = _birthPolicyContext(config);

        HellboxPublication publication = new HellboxPublication(config, commitments, expectedDigest, context);

        require(publication.maxSupply() == 5_555, "scivive supply");
        require(publication.primaryLifetimeCap() == 1, "scivive cap");
        require(publication.maxPerTransaction() == 1, "scivive one per tx");
        require(publication.royaltyBps() == 369, "scivive royalty");
        require(publication.readerEnabled(), "scivive reader");
    }

    // ---------------------------------------------------------------------
    // Commitment encoding checks
    // ---------------------------------------------------------------------

    function testCommitmentsDigestMatchesIndependentEncoding() public {
        HellboxPublication.ReleaseConfig memory config = _native216Config();
        HellboxPublication.CommitmentSet memory commitments = _commitments();

        bytes32 expectedReleaseDigest = _releaseDigest(block.chainid, address(this), config, commitments);

        HellboxPublication publication =
            new HellboxPublication(config, commitments, expectedReleaseDigest, _birthPolicyContext(config));

        bytes32 independentDigest = keccak256(abi.encode(commitments));

        require(publication.commitmentsDigest() == independentDigest, "commitment encoding mismatch");
    }

    function testReleaseDigestMatchesIndependentEncoding() public {
        HellboxPublication.ReleaseConfig memory config = _native216Config();
        HellboxPublication.CommitmentSet memory commitments = _commitments();

        bytes32 expected = _releaseDigest(block.chainid, address(this), config, commitments);

        HellboxPublication publication =
            new HellboxPublication(config, commitments, expected, _birthPolicyContext(config));

        bytes32 independentResult = _releaseDigest(block.chainid, address(this), config, commitments);

        require(independentResult == expected, "release encoding mismatch");
        require(publication.releaseConfigDigest() == expected, "constructor digest mismatch");
    }

    function testWrongExpectedDigestCannotDeploy() public {
        HellboxPublication.ReleaseConfig memory config = _native216Config();
        HellboxPublication.CommitmentSet memory commitments = _commitments();

        bytes32 correctDigest = _releaseDigest(block.chainid, address(this), config, commitments);

        _expectDeploymentRevert(
            config,
            commitments,
            bytes32(uint256(correctDigest) ^ 1),
            HellboxPublication.ReleaseConfigDigestMismatch.selector
        );
    }

    // ---------------------------------------------------------------------
    // Standards baseline
    // ---------------------------------------------------------------------

    function testERC721AndRoyaltyInterfacesAreSupported() public {
        (HellboxPublication publication,,) = _deployNative216();

        require(publication.supportsInterface(0x01ffc9a7), "ERC165 missing");
        require(publication.supportsInterface(0x80ac58cd), "ERC721 missing");
        require(publication.supportsInterface(0x2a55205a), "ERC2981 missing");
    }

    function testDefaultRoyaltyIsConfigured() public {
        (HellboxPublication publication,,) = _deployNative216();

        (address receiver, uint256 amount) = publication.royaltyInfo(1, 1 ether);

        require(receiver == ROYALTY, "royalty receiver");
        require(amount == 0.0369 ether, "royalty amount");
    }

    function testPublicationHasNoGenericOwnableOwner() public {
        (HellboxPublication publication,,) = _deployNative216();

        (bool success, bytes memory returnData) = address(publication).staticcall(abi.encodeWithSignature("owner()"));

        require(!success, "generic owner unexpectedly exists");
        require(returnData.length == 0, "unexpected owner return data");
    }

    // ---------------------------------------------------------------------
    // Constructor validation checks
    // ---------------------------------------------------------------------

    function testRejectsInvalidPublicationKeys() public {
        HellboxPublication.CommitmentSet memory commitments = _commitments();

        string[7] memory invalidKeys = ["", "Hellbox", "-hellbox", "hellbox-", "hellbox--issue", "hell_box", "hell box"];

        for (uint256 i = 0; i < invalidKeys.length; ++i) {
            HellboxPublication.ReleaseConfig memory config = _native216Config();
            config.publicationKey = invalidKeys[i];

            _expectValidationRevert(config, commitments, HellboxPublication.InvalidPublicationKey.selector);
        }
    }

    function testRejectsInvalidCollectionNameAndSymbol() public {
        HellboxPublication.CommitmentSet memory commitments = _commitments();

        HellboxPublication.ReleaseConfig memory config = _native216Config();
        config.collectionName = "";

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidCollectionNameLength.selector);

        config = _native216Config();
        config.collectionSymbol = "BAD SYMBOL";

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidCollectionSymbol.selector);
    }

    function testRejectsInvalidSupplyAndCaps() public {
        HellboxPublication.CommitmentSet memory commitments = _commitments();

        HellboxPublication.ReleaseConfig memory config = _native216Config();
        config.maxSupply = 0;

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidMaxSupply.selector);

        config = _native216Config();
        config.primaryLifetimeCap = 217;

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidPrimaryLifetimeCap.selector);

        config = _native216Config();
        config.maxPerTransaction = 7;

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidMaxPerTransaction.selector);
    }

    function testRejectsInvalidCreatorAndTailRules() public {
        HellboxPublication.CommitmentSet memory commitments = _commitments();

        HellboxPublication.ReleaseConfig memory config = _native216Config();
        config.immediateCreatorCount = 214;
        config.tailReserveCount = 3;

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidCreatorAllocation.selector);

        config = _native216Config();
        config.immediateCreatorRecipient = address(0);

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidImmediateCreatorRecipient.selector);

        config = _native216Config();
        config.tailRecipient = address(0);

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidTailRecipient.selector);
    }

    function testRejectsInvalidRoyaltyRules() public {
        HellboxPublication.CommitmentSet memory commitments = _commitments();

        HellboxPublication.ReleaseConfig memory config = _native216Config();
        config.royaltyBps = 10_001;

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidRoyaltyConfiguration.selector);

        config = _native216Config();
        config.royaltyReceiver = address(0);

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidRoyaltyConfiguration.selector);

        config = _native216Config();
        config.royaltyBps = 0;

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidRoyaltyConfiguration.selector);
    }

    function testRejectsMissingPublisherAuthority() public {
        HellboxPublication.ReleaseConfig memory config = _native216Config();
        config.publisherAuthority = address(0);

        _expectValidationRevert(config, _commitments(), HellboxPublication.InvalidPublisherAuthority.selector);
    }

    function testRejectsInvalidCapabilityDependencies() public {
        HellboxPublication.CommitmentSet memory commitments = _commitments();

        HellboxPublication.ReleaseConfig memory config = _native216Config();
        config.sealEnabled = false;

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidCapabilityConfiguration.selector);

        config = _native216Config();
        config.archiveCompatible = false;

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidCapabilityConfiguration.selector);

        config = _native216Config();
        config.dynamicMetadataEnabled = false;

        _expectValidationRevert(config, commitments, HellboxPublication.InvalidCapabilityConfiguration.selector);
    }

    function testRejectsMissingRequiredCommitments() public {
        HellboxPublication.ReleaseConfig memory config = _native216Config();
        HellboxPublication.CommitmentSet memory commitments = _commitments();

        commitments.publicationManifestDigest = bytes32(0);

        _expectValidationRevert(config, commitments, HellboxPublication.MissingRequiredCommitment.selector);

        commitments = _commitments();
        commitments.packageDigest = bytes32(0);

        _expectValidationRevert(config, commitments, HellboxPublication.MissingRequiredCommitment.selector);
    }

    // ---------------------------------------------------------------------
    // Fixtures
    // ---------------------------------------------------------------------

    function _deployNative216()
        internal
        returns (
            HellboxPublication publication,
            HellboxPublication.ReleaseConfig memory config,
            HellboxPublication.CommitmentSet memory commitments
        )
    {
        config = _native216Config();
        commitments = _commitments();

        bytes32 expectedDigest = _releaseDigest(block.chainid, address(this), config, commitments);

        publication = new HellboxPublication(config, commitments, expectedDigest, _birthPolicyContext(config));
    }

    function _baseConfig() internal pure returns (HellboxPublication.ReleaseConfig memory config) {
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

    function _native216Config() internal pure returns (HellboxPublication.ReleaseConfig memory config) {
        config = _baseConfig();
        config.publicationKey = "hellbox-native-001";
        config.collectionName = "Hellbox Native Issue #1";
        config.collectionSymbol = "HELL001";
    }

    function _commitments() internal pure returns (HellboxPublication.CommitmentSet memory commitments) {
        return _commitmentsForConfig(_native216Config());
    }

    function _commitmentsForConfig(HellboxPublication.ReleaseConfig memory config)
        internal
        pure
        returns (HellboxPublication.CommitmentSet memory commitments)
    {
        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _deploymentPolicies(config);

        commitments.publicationManifestDigest = keccak256("publication-manifest-v1");
        commitments.packageDigest = keccak256("package-v1");
        commitments.fixedCopyRulesDigest =
            keccak256(abi.encode(keccak256("HELLBOX_ENFORCEMENT_V1:FIXED_COPY_RULES"), fixedPolicy));
        commitments.birthTraitsDigest =
            keccak256(abi.encode(keccak256("HELLBOX_ENFORCEMENT_V1:BIRTH_TRAITS"), birthPolicy));
        commitments.randomizationPolicyDigest =
            keccak256(abi.encode(keccak256("HELLBOX_ENFORCEMENT_V1:RANDOMIZATION_POLICY"), randomPolicy));
        commitments.rendererRulesDigest = keccak256("renderer-rules-v1");
        commitments.readerPolicyDigest = keccak256("reader-policy-v1");
        commitments.pricingPoliciesDigest = keccak256("pricing-policies-v1");
        commitments.paymentRoutesDigest = keccak256("payment-routes-v1");
        commitments.mintPhasesDigest = keccak256("mint-phases-v1");
        commitments.royaltyPolicyDigest = keccak256("royalty-policy-v1");
        commitments.treasuryPolicyDigest = keccak256("treasury-policy-v1");
        commitments.metadataPolicyDigest = keccak256("metadata-policy-v1");
        commitments.capabilityPolicyDigest = keccak256("capability-policy-v1");
        commitments.protocolCompatibilityDigest = keccak256("protocol-compatibility-v1");
        commitments.closurePolicyDigest = keccak256("closure-policy-v1");
        commitments.authorityPolicyDigest = keccak256("authority-policy-v1");
        commitments.eventPolicyDigest = keccak256("event-policy-v1");
    }

    function _birthPolicyContext(HellboxPublication.ReleaseConfig memory config)
        internal
        returns (HellboxPublication.BirthPolicyDeploymentContext memory context)
    {
        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _deploymentPolicies(config);

        HellboxBirthPolicyCodeStore store = new HellboxBirthPolicyCodeStore();

        context.codeStore = address(store);
        context.approvedCreationCodeHash = keccak256(type(HellboxBirthPolicy).creationCode);
        context.fixedCopyPolicyPreimage = abi.encode(fixedPolicy);
        context.birthTraitsPolicyPreimage = abi.encode(birthPolicy);
        context.randomizationPolicyPreimage = abi.encode(randomPolicy);
    }

    function _deploymentPolicies(HellboxPublication.ReleaseConfig memory config)
        internal
        pure
        returns (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        )
    {
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
        birthPolicy.axes = new HellboxPublication.BirthTraitAxisEnforcement[](0);

        bytes32 fixedDigest = keccak256(abi.encode(keccak256("HELLBOX_ENFORCEMENT_V1:FIXED_COPY_RULES"), fixedPolicy));

        randomPolicy.enabled = true;
        randomPolicy.policyId = keccak256("HELLBOX_TEST_RANDOMIZATION_V1");
        randomPolicy.schemeVersion = 1;
        randomPolicy.providerConfigDigest = keccak256("HELLBOX_TEST_PROVIDER_CONFIG");
        randomPolicy.copyShuffleMode = keccak256("RANDOM_NON_SEQUENTIAL");
        randomPolicy.fixedIdExclusionsDigest = fixedDigest;
        randomPolicy.traitPoolMode = bytes32(0);
        randomPolicy.markDefectIndependent = false;
        randomPolicy.creatorDefectFairness = bytes32(0);
        randomPolicy.publisherMapKnowledgePolicy = keccak256("NO_FULL_PREKNOWN_MAP");
        randomPolicy.assignmentProofMode = keccak256("HELLBOX_TEST_ASSIGNMENT_PROOF");
    }

    // ---------------------------------------------------------------------
    // Independent test-side encoding
    // ---------------------------------------------------------------------

    function _commitmentsDigest(HellboxPublication.CommitmentSet memory commitments) internal pure returns (bytes32) {
        return keccak256(abi.encode(commitments));
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

    // ---------------------------------------------------------------------
    // Revert helpers
    // ---------------------------------------------------------------------

    function _expectValidationRevert(
        HellboxPublication.ReleaseConfig memory config,
        HellboxPublication.CommitmentSet memory commitments,
        bytes4 expectedSelector
    ) internal {
        bytes32 expectedDigest = _releaseDigest(block.chainid, address(this), config, commitments);

        _expectDeploymentRevert(config, commitments, expectedDigest, expectedSelector);
    }

    function _expectDeploymentRevert(
        HellboxPublication.ReleaseConfig memory config,
        HellboxPublication.CommitmentSet memory commitments,
        bytes32 expectedDigest,
        bytes4 expectedSelector
    ) internal {
        HellboxPublication.BirthPolicyDeploymentContext memory context = _birthPolicyContext(config);

        vm.expectPartialRevert(expectedSelector);
        new HellboxPublication(config, commitments, expectedDigest, context);
    }
}
