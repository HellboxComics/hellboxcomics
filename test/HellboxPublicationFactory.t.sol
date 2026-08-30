// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxPublicationFactory} from "../contracts/HellboxPublicationFactory.sol";

interface IVm {
    function expectPartialRevert(bytes4 revertData) external;
    function prank(address msgSender) external;
}

contract HellboxPublicationFactoryTest {
    IVm internal constant VM =
        IVm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address internal constant CREATOR =
        0x1111111111111111111111111111111111111111;
    address internal constant TAIL =
        0x2222222222222222222222222222222222222222;
    address internal constant ROYALTY =
        0x3333333333333333333333333333333333333333;
    address internal constant PUBLISHER =
        0x4444444444444444444444444444444444444444;
    address internal constant OUTSIDER =
        0x5555555555555555555555555555555555555555;
    address internal constant NEXT_OWNER =
        0x6666666666666666666666666666666666666666;

    uint256 internal constant FACTORY_VERSION = 1;
    uint256 internal constant PUBLICATION_VERSION = 1;
    bytes32 internal constant TEMPLATE_ID =
        keccak256("HELLBOX_PUBLICATION");
    bytes32 internal constant DEPLOYMENT_MODE =
        keccak256("FULL_DEPLOYMENT");
    bytes32 internal constant RELEASE_CONFIG_DOMAIN =
        keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");

    uint256 internal constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 internal constant CONFIG_SCHEMA_VERSION = 1;

    function testFactoryIdentityAndInitialAuthority() public {
        HellboxPublicationFactory factory =
            new HellboxPublicationFactory(address(this));

        require(factory.owner() == address(this), "owner");
        require(factory.pendingOwner() == address(0), "pending owner");
        require(
            factory.FACTORY_VERSION() == FACTORY_VERSION,
            "factory version"
        );
        require(
            factory.PUBLICATION_VERSION() == PUBLICATION_VERSION,
            "publication version"
        );
        require(factory.TEMPLATE_ID() == TEMPLATE_ID, "template id");
        require(
            factory.DEPLOYMENT_MODE() == DEPLOYMENT_MODE,
            "deployment mode"
        );
        require(factory.publicationCount() == 0, "initial count");
    }

    function testOwnerPublishesAndRegistersAuthenticPublication() public {
        HellboxPublicationFactory factory =
            new HellboxPublicationFactory(address(this));

        HellboxPublication.ReleaseConfig memory config =
            _validConfig("hellbox-native-001");
        HellboxPublication.CommitmentSet memory commitments =
            _commitments();

        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );
        bytes32 publicationKeyHash =
            keccak256(bytes(config.publicationKey));

        address publicationAddress = factory.publish(
            config,
            commitments,
            expectedDigest
        );

        require(publicationAddress != address(0), "publication");
        require(
            factory.isPublication(publicationAddress),
            "is publication"
        );
        require(
            factory.publicationByReleaseDigest(expectedDigest) ==
                publicationAddress,
            "digest lookup"
        );
        require(
            factory.publicationByKeyHash(publicationKeyHash) ==
                publicationAddress,
            "key lookup"
        );
        require(
            factory.publicationCount() == 1,
            "publication count"
        );
        require(
            factory.publications(0) == publicationAddress,
            "ordered publication"
        );

        HellboxPublication publication =
            HellboxPublication(publicationAddress);

        require(
            publication.factory() == address(factory),
            "reported factory"
        );
        require(
            publication.releaseChainId() == block.chainid,
            "reported chain"
        );
        require(
            publication.TEMPLATE_ID() == TEMPLATE_ID,
            "reported template"
        );
        require(
            publication.PUBLICATION_VERSION() ==
                PUBLICATION_VERSION,
            "reported publication version"
        );
        require(
            publication.releaseConfigDigest() == expectedDigest,
            "reported digest"
        );
        require(
            keccak256(bytes(publication.publicationKey())) ==
                publicationKeyHash,
            "reported publication key"
        );
    }

    function testNonOwnerCannotPublish() public {
        HellboxPublicationFactory factory =
            new HellboxPublicationFactory(address(this));

        HellboxPublication.ReleaseConfig memory config =
            _validConfig("hellbox-native-001");
        HellboxPublication.CommitmentSet memory commitments =
            _commitments();

        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );

        VM.expectPartialRevert(
            bytes4(
                keccak256("OwnableUnauthorizedAccount(address)")
            )
        );
        VM.prank(OUTSIDER);
        factory.publish(config, commitments, expectedDigest);
    }

    function testDuplicatePublicationKeyIsRejected() public {
        HellboxPublicationFactory factory =
            new HellboxPublicationFactory(address(this));

        HellboxPublication.ReleaseConfig memory firstConfig =
            _validConfig("hellbox-native-001");
        HellboxPublication.CommitmentSet memory commitments =
            _commitments();

        bytes32 firstDigest = _releaseDigest(
            block.chainid,
            address(factory),
            firstConfig,
            commitments
        );

        address firstPublication = factory.publish(
            firstConfig,
            commitments,
            firstDigest
        );

        HellboxPublication.ReleaseConfig memory secondConfig =
            _validConfig("hellbox-native-001");
        secondConfig.collectionName =
            "Hellbox Native Issue #1 - Repriced";

        bytes32 secondDigest = _releaseDigest(
            block.chainid,
            address(factory),
            secondConfig,
            commitments
        );

        require(
            secondDigest != firstDigest,
            "test requires distinct digests"
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .DuplicatePublicationKey
                .selector
        );
        factory.publish(
            secondConfig,
            commitments,
            secondDigest
        );

        require(
            factory.publicationCount() == 1,
            "duplicate key changed count"
        );
        require(
            factory.publicationByKeyHash(
                keccak256(bytes(firstConfig.publicationKey))
            ) == firstPublication,
            "duplicate key replaced provenance"
        );
    }

    function testDuplicateReleaseDigestIsRejected() public {
        HellboxPublicationFactory factory =
            new HellboxPublicationFactory(address(this));

        HellboxPublication.ReleaseConfig memory firstConfig =
            _validConfig("hellbox-native-001");
        HellboxPublication.CommitmentSet memory commitments =
            _commitments();

        bytes32 firstDigest = _releaseDigest(
            block.chainid,
            address(factory),
            firstConfig,
            commitments
        );

        address firstPublication = factory.publish(
            firstConfig,
            commitments,
            firstDigest
        );

        HellboxPublication.ReleaseConfig memory secondConfig =
            _validConfig("hellbox-native-002");

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .DuplicateReleaseConfigDigest
                .selector
        );
        factory.publish(
            secondConfig,
            commitments,
            firstDigest
        );

        require(
            factory.publicationCount() == 1,
            "duplicate digest changed count"
        );
        require(
            factory.publicationByReleaseDigest(firstDigest) ==
                firstPublication,
            "duplicate digest replaced provenance"
        );
    }

    function testSamePublicationKeyCanExistInSeparateFactoryGeneration()
        public
    {
        HellboxPublicationFactory firstFactory =
            new HellboxPublicationFactory(address(this));
        HellboxPublicationFactory secondFactory =
            new HellboxPublicationFactory(address(this));

        HellboxPublication.ReleaseConfig memory config =
            _validConfig("hellbox-native-001");
        HellboxPublication.CommitmentSet memory commitments =
            _commitments();

        bytes32 firstDigest = _releaseDigest(
            block.chainid,
            address(firstFactory),
            config,
            commitments
        );
        bytes32 secondDigest = _releaseDigest(
            block.chainid,
            address(secondFactory),
            config,
            commitments
        );

        require(
            firstDigest != secondDigest,
            "factory must bind release digest"
        );

        address firstPublication = firstFactory.publish(
            config,
            commitments,
            firstDigest
        );
        address secondPublication = secondFactory.publish(
            config,
            commitments,
            secondDigest
        );

        require(
            firstPublication != secondPublication,
            "distinct factory publications"
        );
        require(
            firstFactory.isPublication(firstPublication),
            "first provenance"
        );
        require(
            secondFactory.isPublication(secondPublication),
            "second provenance"
        );
    }

    function testOwnershipUsesTwoStepRotation() public {
        HellboxPublicationFactory factory =
            new HellboxPublicationFactory(address(this));

        factory.transferOwnership(NEXT_OWNER);

        require(
            factory.owner() == address(this),
            "owner changed before acceptance"
        );
        require(
            factory.pendingOwner() == NEXT_OWNER,
            "pending owner"
        );

        VM.prank(NEXT_OWNER);
        factory.acceptOwnership();

        require(factory.owner() == NEXT_OWNER, "rotated owner");
        require(factory.pendingOwner() == address(0), "pending cleared");

        HellboxPublication.ReleaseConfig memory config =
            _validConfig("hellbox-native-001");
        HellboxPublication.CommitmentSet memory commitments =
            _commitments();

        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );

        VM.expectPartialRevert(
            bytes4(
                keccak256("OwnableUnauthorizedAccount(address)")
            )
        );
        factory.publish(config, commitments, expectedDigest);

        VM.prank(NEXT_OWNER);
        address publicationAddress = factory.publish(
            config,
            commitments,
            expectedDigest
        );

        require(
            factory.isPublication(publicationAddress),
            "new owner publish"
        );
    }

    function testOwnershipRenunciationIsDisabled() public {
        HellboxPublicationFactory factory =
            new HellboxPublicationFactory(address(this));

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .OwnershipRenunciationDisabled
                .selector
        );
        factory.renounceOwnership();

        require(
            factory.owner() == address(this),
            "owner changed after blocked renounce"
        );
    }

    function testWrongExpectedDigestCannotBecomeOfficialProvenance()
        public
    {
        HellboxPublicationFactory factory =
            new HellboxPublicationFactory(address(this));

        HellboxPublication.ReleaseConfig memory config =
            _validConfig("hellbox-native-001");
        HellboxPublication.CommitmentSet memory commitments =
            _commitments();

        bytes32 correctDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );
        bytes32 wrongDigest =
            bytes32(uint256(correctDigest) ^ uint256(1));

        VM.expectPartialRevert(
            HellboxPublication.ReleaseConfigDigestMismatch.selector
        );
        factory.publish(config, commitments, wrongDigest);

        require(
            factory.publicationCount() == 0,
            "failed deploy recorded"
        );
        require(
            factory.publicationByReleaseDigest(wrongDigest) ==
                address(0),
            "wrong digest recorded"
        );
        require(
            factory.publicationByKeyHash(
                keccak256(bytes(config.publicationKey))
            ) == address(0),
            "failed key recorded"
        );
    }

    function _validConfig(
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

        // Keep the factory test focused on deployment/provenance.
        // Capability combinations are independently covered by the kernel suite.
        config.readerEnabled = false;
        config.sealEnabled = false;
        config.archiveCompatible = false;
        config.dynamicMetadataEnabled = false;
        config.erc6551Compatible = false;
        config.rewardsCompatible = false;
        config.hellforgeCompatible = false;
        config.contextualTraitsEnabled = false;
    }

    function _commitments() internal pure returns (
        HellboxPublication.CommitmentSet memory commitments
    ) {
        commitments.publicationManifestDigest =
            keccak256("publication-manifest");
        commitments.packageDigest =
            keccak256("package");
        commitments.fixedCopyRulesDigest =
            keccak256("fixed-copy-rules");
        commitments.birthTraitsDigest =
            keccak256("birth-traits");
        commitments.randomizationPolicyDigest =
            keccak256("randomization-policy");
        commitments.rendererRulesDigest =
            keccak256("renderer-rules");
        commitments.readerPolicyDigest =
            keccak256("reader-policy");
        commitments.pricingPoliciesDigest =
            keccak256("pricing-policies");
        commitments.paymentRoutesDigest =
            keccak256("payment-routes");
        commitments.mintPhasesDigest =
            keccak256("mint-phases");
        commitments.royaltyPolicyDigest =
            keccak256("royalty-policy");
        commitments.treasuryPolicyDigest =
            keccak256("treasury-policy");
        commitments.metadataPolicyDigest =
            keccak256("metadata-policy");
        commitments.capabilityPolicyDigest =
            keccak256("capability-policy");
        commitments.protocolCompatibilityDigest =
            keccak256("protocol-compatibility");
        commitments.closurePolicyDigest =
            keccak256("closure-policy");
        commitments.authorityPolicyDigest =
            keccak256("authority-policy");
        commitments.eventPolicyDigest =
            keccak256("event-policy");
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
