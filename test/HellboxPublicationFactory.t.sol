// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxPublicationFactory} from "../contracts/HellboxPublicationFactory.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";

interface IVm {
    function expectPartialRevert(bytes4 revertData) external;
    function expectRevert() external;
    function prank(address msgSender) external;
}

contract RawRuntimeCodeStore {
    constructor(bytes memory runtimeCode) {
        assembly ("memory-safe") {
            return(add(runtimeCode, 0x20), mload(runtimeCode))
        }
    }
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
    address internal constant BIRTH_POLICY_CODE_STORE =
        0x7777777777777777777777777777777777777777;

    uint256 internal constant FACTORY_VERSION = 1;
    uint256 internal constant PUBLICATION_VERSION = 1;
    uint256 internal constant EIP170_RUNTIME_LIMIT = 24_576;
    uint256 internal constant EIP3860_INITCODE_LIMIT = 49_152;

    event PublicationInitCodeMeasured(
        uint256 initCodeLength,
        uint256 headroom
    );

    bytes32 internal constant TEMPLATE_ID =
        keccak256("HELLBOX_PUBLICATION");
    bytes32 internal constant DEPLOYMENT_MODE =
        keccak256("FULL_DEPLOYMENT");
    bytes32 internal constant RELEASE_CONFIG_DOMAIN =
        keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");
    bytes32 internal constant DRAND_PROVIDER_CONFIG_DIGEST =
        0x0d191efbb2f605bf73b6f3c4819b21bc8c7a64393c6dcfd43b6b2f6b5be401e3;

    uint256 internal constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 internal constant CONFIG_SCHEMA_VERSION = 1;

    function testFactoryIdentityAndInitialAuthority() public {
        HellboxPublicationFactory factory = _newFactory();

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

        require(
            factory.approvedPublicationCreationCodeHash() ==
                _publicationCreationCodeHash(),
            "approved creation code hash"
        );

        address codeStore = factory.birthPolicyCodeStore();
        require(codeStore != address(0), "birth policy code store");
        require(
            codeStore.code.length ==
                type(HellboxBirthPolicy).creationCode.length + 1,
            "birth policy code store length"
        );

        require(
            factory.approvedBirthPolicyCreationCodeHash() ==
                _birthPolicyCreationCodeHash(),
            "approved birth policy creation code hash"
        );

        require(
            address(factory).code.length < EIP170_RUNTIME_LIMIT,
            "factory runtime exceeds EIP-170"
        );

        require(factory.publicationCount() == 0, "initial count");
    }

    function testFactoryRejectsZeroApprovedCreationCodeHash() public {
        VM.expectPartialRevert(
            HellboxPublicationFactory
                .InvalidApprovedPublicationCreationCodeHash
                .selector
        );

        new HellboxPublicationFactory(
            address(this),
            bytes32(0),
            BIRTH_POLICY_CODE_STORE,
            _birthPolicyCreationCodeHash()
        );
    }

    function testFactoryRejectsZeroBirthPolicyCodeStore() public {
        VM.expectPartialRevert(
            HellboxPublicationFactory
                .InvalidBirthPolicyCodeStore
                .selector
        );

        new HellboxPublicationFactory(
            address(this),
            _publicationCreationCodeHash(),
            address(0),
            _birthPolicyCreationCodeHash()
        );
    }

    function testFactoryRejectsZeroApprovedBirthPolicyCreationCodeHash()
        public
    {
        VM.expectPartialRevert(
            HellboxPublicationFactory
                .InvalidApprovedBirthPolicyCreationCodeHash
                .selector
        );

        new HellboxPublicationFactory(
            address(this),
            _publicationCreationCodeHash(),
            BIRTH_POLICY_CODE_STORE,
            bytes32(0)
        );
    }

    function testOwnerPublishesAndRegistersAuthenticPublication() public {
        HellboxPublicationFactory factory = _newFactory();

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

        address publicationAddress = _publish(
            factory,
            config,
            commitments,
            expectedDigest,
            _publicationCreationCode()
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

        address policyAddress = publication.birthPolicy();
        require(policyAddress != address(0), "birth policy");
        require(policyAddress.code.length > 0, "birth policy code");

        HellboxBirthPolicy policy = HellboxBirthPolicy(policyAddress);
        require(
            policy.publication() == publicationAddress,
            "birth policy publication"
        );
        require(policy.maxSupply() == config.maxSupply, "birth policy supply");
        require(
            policy.fixedCopyRulesDigest() == commitments.fixedCopyRulesDigest,
            "birth policy fixed digest"
        );
    }

    function testUnapprovedPublicationCreationCodeIsRejected() public {
        HellboxPublicationFactory factory = _newFactory();

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

        bytes memory unapprovedCreationCode = hex"00";

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .UnapprovedPublicationCreationCode
                .selector
        );

        _publish(
            factory,
            config,
            commitments,
            expectedDigest,
            unapprovedCreationCode
        );

        require(
            factory.publicationCount() == 0,
            "unapproved code changed count"
        );

        require(
            factory.publicationByReleaseDigest(expectedDigest) ==
                address(0),
            "unapproved digest recorded"
        );

        require(
            factory.publicationByKeyHash(
                keccak256(bytes(config.publicationKey))
            ) == address(0),
            "unapproved key recorded"
        );
    }

    function testNonOwnerCannotPublish() public {
        HellboxPublicationFactory factory = _newFactory();

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

        _publish(
            factory,
            config,
            commitments,
            expectedDigest,
            _publicationCreationCode()
        );
    }

    function testDuplicatePublicationKeyIsRejected() public {
        HellboxPublicationFactory factory = _newFactory();

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

        address firstPublication = _publish(
            factory,
            firstConfig,
            commitments,
            firstDigest,
            _publicationCreationCode()
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

        _publish(
            factory,
            secondConfig,
            commitments,
            secondDigest,
            _publicationCreationCode()
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
        HellboxPublicationFactory factory = _newFactory();

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

        address firstPublication = _publish(
            factory,
            firstConfig,
            commitments,
            firstDigest,
            _publicationCreationCode()
        );

        HellboxPublication.ReleaseConfig memory secondConfig =
            _validConfig("hellbox-native-002");

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .DuplicateReleaseConfigDigest
                .selector
        );

        _publish(
            factory,
            secondConfig,
            commitments,
            firstDigest,
            _publicationCreationCode()
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
        HellboxPublicationFactory firstFactory = _newFactory();
        HellboxPublicationFactory secondFactory = _newFactory();

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

        address firstPublication = _publish(
            firstFactory,
            config,
            commitments,
            firstDigest,
            _publicationCreationCode()
        );

        address secondPublication = _publish(
            secondFactory,
            config,
            commitments,
            secondDigest,
            _publicationCreationCode()
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

    function testNativePublicationCreatePayloadHasEip3860Headroom() public {
        HellboxPublicationFactory factory = _newFactory();
        HellboxPublication.ReleaseConfig memory config =
            _validConfig("hellbox-native-001");

        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _nativePolicies();

        HellboxPublication.CommitmentSet memory commitments =
            _baseCommitments();
        commitments.fixedCopyRulesDigest = _fixedDigest(fixedPolicy);
        commitments.birthTraitsDigest = _birthDigest(birthPolicy);
        commitments.randomizationPolicyDigest = _randomDigest(randomPolicy);

        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );

        HellboxPublication.BirthPolicyDeploymentContext memory context =
            HellboxPublication.BirthPolicyDeploymentContext({
                codeStore: factory.birthPolicyCodeStore(),
                approvedCreationCodeHash:
                    factory.approvedBirthPolicyCreationCodeHash(),
                fixedCopyPolicyPreimage: abi.encode(fixedPolicy),
                birthTraitsPolicyPreimage: abi.encode(birthPolicy),
                randomizationPolicyPreimage: abi.encode(randomPolicy)
            });

        bytes memory initCode = bytes.concat(
            _publicationCreationCode(),
            abi.encode(
                config,
                commitments,
                expectedDigest,
                context
            )
        );

        require(
            initCode.length <= EIP3860_INITCODE_LIMIT,
            "native publication initcode exceeds EIP-3860"
        );

        emit PublicationInitCodeMeasured(
            initCode.length,
            EIP3860_INITCODE_LIMIT - initCode.length
        );
    }

    function testNativeBirthPolicyDeploymentWiresTraitCompanion() public {
        HellboxPublicationFactory factory = _newFactory();
        HellboxPublication.ReleaseConfig memory config =
            _validConfig("hellbox-native-traits");

        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _nativePolicies();

        HellboxPublication.CommitmentSet memory commitments =
            _baseCommitments();
        commitments.fixedCopyRulesDigest = _fixedDigest(fixedPolicy);
        commitments.birthTraitsDigest = _birthDigest(birthPolicy);
        commitments.randomizationPolicyDigest = _randomDigest(randomPolicy);

        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );

        HellboxPublicationFactory.BirthPolicyPreimages memory preimages =
            HellboxPublicationFactory.BirthPolicyPreimages({
                fixedCopyPolicyPreimage: abi.encode(fixedPolicy),
                birthTraitsPolicyPreimage: abi.encode(birthPolicy),
                randomizationPolicyPreimage: abi.encode(randomPolicy)
            });

        address publicationAddress = factory.publish(
            config,
            commitments,
            expectedDigest,
            preimages,
            _publicationCreationCode()
        );

        HellboxPublication publication =
            HellboxPublication(publicationAddress);
        HellboxBirthPolicy policy =
            HellboxBirthPolicy(publication.birthPolicy());

        require(policy.publication() == publicationAddress, "native policy owner");
        require(policy.fixedCopyRuleCount() == 7, "native fixed rules");
        require(policy.pressMarkEnabled(), "native mark enabled");
        require(policy.pressDefectEnabled(), "native defect enabled");
        require(
            policy.markInitialCount(keccak256("HELLBOUND")) == 6,
            "native hellbound inventory"
        );
        require(
            policy.fixedCopyRequiredMark(66) == keccak256("HELLBOUND"),
            "native 066 mark"
        );
    }

    function testSciViveTraitDisabledBirthPolicyDeploys() public {
        HellboxPublicationFactory factory = _newFactory();
        HellboxPublication.ReleaseConfig memory config =
            _validConfig("scivive");

        config.collectionName = "SciVive";
        config.collectionSymbol = "SCIVIVE";
        config.maxSupply = 5_555;
        config.primaryLifetimeCap = 1;
        config.immediateCreatorRecipient = address(0);
        config.immediateCreatorCount = 0;
        config.tailRecipient = address(0);
        config.tailReserveCount = 0;

        HellboxPublication.CommitmentSet memory commitments =
            _commitmentsForConfig(config);
        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );

        address publicationAddress = _publish(
            factory,
            config,
            commitments,
            expectedDigest,
            _publicationCreationCode()
        );

        HellboxBirthPolicy policy = HellboxBirthPolicy(
            HellboxPublication(publicationAddress).birthPolicy()
        );

        require(policy.maxSupply() == 5_555, "scivive policy supply");
        require(policy.fixedCopyRuleCount() == 0, "scivive fixed rules");
        require(!policy.pressMarkEnabled(), "scivive mark disabled");
        require(!policy.pressDefectEnabled(), "scivive defect disabled");
        require(policy.randomizationEnabled(), "scivive randomization");
    }

    function testWrongBirthPolicyCreationCodeHashRevertsAtomically() public {
        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();
        bytes32 wrongPolicyHash = bytes32(
            uint256(_birthPolicyCreationCodeHash()) ^ uint256(1)
        );
        HellboxPublicationFactory factory = new HellboxPublicationFactory(
            address(this),
            _publicationCreationCodeHash(),
            address(store),
            wrongPolicyHash
        );

        HellboxPublication.ReleaseConfig memory config =
            _validConfig("wrong-policy-hash");
        HellboxPublication.CommitmentSet memory commitments = _commitments();
        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );

        VM.expectPartialRevert(
            HellboxPublication.BirthPolicyCreationCodeHashMismatch.selector
        );
        _publish(
            factory,
            config,
            commitments,
            expectedDigest,
            _publicationCreationCode()
        );

        _assertNoProvenance(factory, config, expectedDigest);
    }

    function testNonStopBirthPolicyCodeStoreRevertsAtomically() public {
        bytes memory badRuntime = bytes.concat(
            hex"01",
            type(HellboxBirthPolicy).creationCode
        );
        RawRuntimeCodeStore store = new RawRuntimeCodeStore(badRuntime);
        HellboxPublicationFactory factory = new HellboxPublicationFactory(
            address(this),
            _publicationCreationCodeHash(),
            address(store),
            _birthPolicyCreationCodeHash()
        );

        HellboxPublication.ReleaseConfig memory config =
            _validConfig("bad-policy-prefix");
        HellboxPublication.CommitmentSet memory commitments = _commitments();
        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );

        VM.expectPartialRevert(
            HellboxPublication.InvalidBirthPolicyCodeStorePrefix.selector
        );
        _publish(
            factory,
            config,
            commitments,
            expectedDigest,
            _publicationCreationCode()
        );

        _assertNoProvenance(factory, config, expectedDigest);
    }

    function testShortBirthPolicyCodeStoreRevertsAtomically() public {
        RawRuntimeCodeStore store = new RawRuntimeCodeStore(hex"00");
        HellboxPublicationFactory factory = new HellboxPublicationFactory(
            address(this),
            _publicationCreationCodeHash(),
            address(store),
            _birthPolicyCreationCodeHash()
        );

        HellboxPublication.ReleaseConfig memory config =
            _validConfig("short-policy-store");
        HellboxPublication.CommitmentSet memory commitments = _commitments();
        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );

        VM.expectPartialRevert(
            HellboxPublication.InvalidBirthPolicyCodeStore.selector
        );
        _publish(
            factory,
            config,
            commitments,
            expectedDigest,
            _publicationCreationCode()
        );

        _assertNoProvenance(factory, config, expectedDigest);
    }

    function testMalformedBirthPolicyPreimageRevertsAtomically() public {
        HellboxPublicationFactory factory = _newFactory();
        HellboxPublication.ReleaseConfig memory config =
            _validConfig("malformed-policy-preimage");
        HellboxPublication.CommitmentSet memory commitments = _commitments();
        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );

        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _deploymentPolicies(config);
        fixedPolicy;

        HellboxPublicationFactory.BirthPolicyPreimages memory preimages =
            HellboxPublicationFactory.BirthPolicyPreimages({
                fixedCopyPolicyPreimage: hex"deadbeef",
                birthTraitsPolicyPreimage: abi.encode(birthPolicy),
                randomizationPolicyPreimage: abi.encode(randomPolicy)
            });

        VM.expectRevert();
        factory.publish(
            config,
            commitments,
            expectedDigest,
            preimages,
            _publicationCreationCode()
        );

        _assertNoProvenance(factory, config, expectedDigest);
    }

    function testMismatchedBirthPolicyPreimageRevertsAtomically() public {
        HellboxPublicationFactory factory = _newFactory();
        HellboxPublication.ReleaseConfig memory config =
            _validConfig("bad-policy-preimage");
        HellboxPublication.CommitmentSet memory commitments = _commitments();
        bytes32 expectedDigest = _releaseDigest(
            block.chainid,
            address(factory),
            config,
            commitments
        );

        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _deploymentPolicies(config);
        fixedPolicy.rules[0].copyId = 7;

        VM.expectPartialRevert(
            HellboxBirthPolicy.FixedCopyRulesDigestMismatch.selector
        );
        HellboxPublicationFactory.BirthPolicyPreimages memory preimages =
            HellboxPublicationFactory.BirthPolicyPreimages({
                fixedCopyPolicyPreimage: abi.encode(fixedPolicy),
                birthTraitsPolicyPreimage: abi.encode(birthPolicy),
                randomizationPolicyPreimage: abi.encode(randomPolicy)
            });

        factory.publish(
            config,
            commitments,
            expectedDigest,
            preimages,
            _publicationCreationCode()
        );

        _assertNoProvenance(factory, config, expectedDigest);
    }

    function testOwnershipUsesTwoStepRotation() public {
        HellboxPublicationFactory factory = _newFactory();
        address birthPolicyCodeStoreBefore = factory.birthPolicyCodeStore();

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

        require(
            factory.approvedPublicationCreationCodeHash() ==
                _publicationCreationCodeHash(),
            "creation code hash changed"
        );

        require(
            factory.birthPolicyCodeStore() ==
                birthPolicyCodeStoreBefore,
            "birth policy code store changed"
        );

        require(
            factory.approvedBirthPolicyCreationCodeHash() ==
                _birthPolicyCreationCodeHash(),
            "birth policy creation code hash changed"
        );

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

        _publish(
            factory,
            config,
            commitments,
            expectedDigest,
            _publicationCreationCode()
        );

        VM.prank(NEXT_OWNER);

        address publicationAddress = _publish(
            factory,
            config,
            commitments,
            expectedDigest,
            _publicationCreationCode()
        );

        require(
            factory.isPublication(publicationAddress),
            "new owner publish"
        );
    }

    function testOwnershipRenunciationIsDisabled() public {
        HellboxPublicationFactory factory = _newFactory();

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
        HellboxPublicationFactory factory = _newFactory();

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

        _publish(
            factory,
            config,
            commitments,
            wrongDigest,
            _publicationCreationCode()
        );

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

    function _newFactory()
        internal
        returns (HellboxPublicationFactory factory)
    {
        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();

        factory = new HellboxPublicationFactory(
            address(this),
            _publicationCreationCodeHash(),
            address(store),
            _birthPolicyCreationCodeHash()
        );
    }

    function _publicationCreationCode()
        internal
        pure
        returns (bytes memory)
    {
        return type(HellboxPublication).creationCode;
    }

    function _publicationCreationCodeHash()
        internal
        pure
        returns (bytes32)
    {
        return keccak256(type(HellboxPublication).creationCode);
    }

    function _birthPolicyCreationCodeHash()
        internal
        pure
        returns (bytes32)
    {
        return keccak256(type(HellboxBirthPolicy).creationCode);
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
        return _commitmentsForConfig(_validConfig("hellbox-native-001"));
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

        commitments = _baseCommitments();
        commitments.fixedCopyRulesDigest = _fixedDigest(fixedPolicy);
        commitments.birthTraitsDigest = _birthDigest(birthPolicy);
        commitments.randomizationPolicyDigest = _randomDigest(randomPolicy);
    }

    function _baseCommitments() internal pure returns (
        HellboxPublication.CommitmentSet memory commitments
    ) {
        commitments.publicationManifestDigest =
            keccak256("publication-manifest");
        commitments.packageDigest =
            keccak256("package");
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

    function _publish(
        HellboxPublicationFactory factory,
        HellboxPublication.ReleaseConfig memory config,
        HellboxPublication.CommitmentSet memory commitments,
        bytes32 expectedDigest,
        bytes memory creationCode
    ) internal returns (address publicationAddress) {
        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthPolicy,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _deploymentPolicies(config);

        HellboxPublicationFactory.BirthPolicyPreimages memory preimages =
            HellboxPublicationFactory.BirthPolicyPreimages({
                fixedCopyPolicyPreimage: abi.encode(fixedPolicy),
                birthTraitsPolicyPreimage: abi.encode(birthPolicy),
                randomizationPolicyPreimage: abi.encode(randomPolicy)
            });

        publicationAddress = factory.publish(
            config,
            commitments,
            expectedDigest,
            preimages,
            creationCode
        );
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

        randomPolicy.enabled = true;
        randomPolicy.policyId = keccak256("HELLBOX_TEST_RANDOMIZATION_V1");
        randomPolicy.schemeVersion = 1;
        randomPolicy.providerConfigDigest =
            DRAND_PROVIDER_CONFIG_DIGEST;
        randomPolicy.copyShuffleMode =
            keccak256("RANDOM_NON_SEQUENTIAL");
        randomPolicy.fixedIdExclusionsDigest = _fixedDigest(fixedPolicy);
        randomPolicy.traitPoolMode = bytes32(0);
        randomPolicy.markDefectIndependent = false;
        randomPolicy.creatorDefectFairness = bytes32(0);
        randomPolicy.publisherMapKnowledgePolicy =
            keccak256("NO_FULL_PREKNOWN_MAP");
        randomPolicy.assignmentProofMode =
            keccak256("HELLBOX_TEST_ASSIGNMENT_PROOF");
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

    function _assertNoProvenance(
        HellboxPublicationFactory factory,
        HellboxPublication.ReleaseConfig memory config,
        bytes32 expectedDigest
    ) internal view {
        require(factory.publicationCount() == 0, "failed deploy recorded");
        require(
            factory.publicationByReleaseDigest(expectedDigest) == address(0),
            "failed digest recorded"
        );
        require(
            factory.publicationByKeyHash(
                keccak256(bytes(config.publicationKey))
            ) == address(0),
            "failed key recorded"
        );
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
        randomPolicy.policyId = keccak256("HELLBOX_RANDOMIZATION_TEST_V1");
        randomPolicy.schemeVersion = 1;
        randomPolicy.providerConfigDigest =
            DRAND_PROVIDER_CONFIG_DIGEST;
        randomPolicy.copyShuffleMode = keccak256("RANDOM_NON_SEQUENTIAL");
        randomPolicy.fixedIdExclusionsDigest = _fixedDigest(fixedPolicy);
        randomPolicy.traitPoolMode = keccak256("GLOBAL_SHARED");
        randomPolicy.markDefectIndependent = true;
        randomPolicy.creatorDefectFairness = keccak256("SHARED_RANDOM");
        randomPolicy.publisherMapKnowledgePolicy = keccak256("NO_FULL_PREKNOWN_MAP");
        randomPolicy.assignmentProofMode = keccak256("TEST_ASSIGNMENT_PROOF");
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
