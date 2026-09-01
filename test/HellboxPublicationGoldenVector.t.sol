// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxPublication} from "../contracts/HellboxPublication.sol";

/// @dev Test-only inert code store used solely to instantiate the publication
///      while preserving the pre-existing HELLBOX_ABI_V1 golden CommitmentSet.
///      Companion correctness is covered by the dedicated BirthPolicy/factory
///      integration suites; this file must not rewrite its independent vectors.
contract GoldenVectorBirthPolicyCodeStore {
    constructor() {
        // runtime[0] = STOP; runtime[1..] is tiny creation code that returns
        // a one-byte STOP runtime and ignores appended constructor arguments.
        bytes memory runtimeCode = hex"00600060005360016000f3";
        assembly ("memory-safe") {
            return(add(runtimeCode, 0x20), mload(runtimeCode))
        }
    }
}

/// @notice Cross-language golden vector for HELLBOX_ABI_V1.
/// @dev The expected values in this file were produced independently by
///      test/press/releaseFingerprint.golden.mjs using viem. If the JavaScript
///      encoder or Solidity encoder ever changes incompatibly, this test fails.
contract HellboxPublicationGoldenVectorTest {
    uint256 internal constant GOLDEN_CHAIN_ID = 943;

    address internal constant GOLDEN_FACTORY =
        0x5555555555555555555555555555555555555555;

    address internal constant CREATOR =
        0x1111111111111111111111111111111111111111;
    address internal constant TAIL =
        0x2222222222222222222222222222222222222222;
    address internal constant ROYALTY =
        0x3333333333333333333333333333333333333333;
    address internal constant PUBLISHER =
        0x4444444444444444444444444444444444444444;

    bytes32 internal constant EXPECTED_TEMPLATE_ID =
        0xa90f1cffe90023915c9a1a9852bcc46202522e86f77973f82c4235e837abdfba;

    bytes32 internal constant EXPECTED_RELEASE_CONFIG_DOMAIN =
        0x2bc593326bff52216bd201a52f68bc01b8a51a43c6b742788d138a7abe94ca25;

    bytes32 internal constant EXPECTED_COMMITMENTS_DIGEST =
        0xb6a0722a62b0309c6a082152ddff7e1ffc544669e8d690047a7516799081ecf6;

    bytes32 internal constant EXPECTED_RELEASE_CONFIG_DIGEST =
        0x66e6697d8fde60531eebed0882030a1c6beecf086b04926599a39878d4e0d15d;

    function testJavascriptAndSolidityGoldenVectorMatch() public {
        HellboxPublication.ReleaseConfig memory config =
            _goldenConfig();

        HellboxPublication.CommitmentSet memory commitments =
            _goldenCommitments();

        // Deploy one valid local helper instance. Its own frozen digest uses
        // the local Foundry chain and this test contract as its factory.
        bytes32 localDeploymentDigest = _releaseDigest(
            block.chainid,
            address(this),
            config,
            commitments
        );

        GoldenVectorBirthPolicyCodeStore store =
            new GoldenVectorBirthPolicyCodeStore();

        HellboxPublication.BirthPolicyDeploymentContext memory context =
            HellboxPublication.BirthPolicyDeploymentContext({
                codeStore: address(store),
                approvedCreationCodeHash:
                    keccak256(hex"600060005360016000f3"),
                fixedCopyPolicyPreimage: bytes(""),
                birthTraitsPolicyPreimage: bytes(""),
                randomizationPolicyPreimage: bytes("")
            });

        HellboxPublication publication =
            new HellboxPublication(
                config,
                commitments,
                localDeploymentDigest,
                context
            );

        require(
            publication.TEMPLATE_ID() == EXPECTED_TEMPLATE_ID,
            "template id mismatch"
        );

        require(
            publication.RELEASE_CONFIG_DOMAIN() ==
                EXPECTED_RELEASE_CONFIG_DOMAIN,
            "release domain mismatch"
        );

        require(
            publication.COMMITMENT_SCHEME_VERSION() == 1,
            "commitment version mismatch"
        );

        require(
            publication.CONFIG_SCHEMA_VERSION() == 1,
            "config schema version mismatch"
        );

        require(
            publication.PUBLICATION_VERSION() == 1,
            "publication version mismatch"
        );

        bytes32 solidityCommitmentsDigest =
            publication.computeCommitmentsDigest(commitments);

        require(
            solidityCommitmentsDigest ==
                EXPECTED_COMMITMENTS_DIGEST,
            "commitments golden vector mismatch"
        );

        bytes32 solidityReleaseConfigDigest =
            publication.computeReleaseConfigDigest(
                GOLDEN_CHAIN_ID,
                GOLDEN_FACTORY,
                config,
                commitments
            );

        require(
            solidityReleaseConfigDigest ==
                EXPECTED_RELEASE_CONFIG_DIGEST,
            "release golden vector mismatch"
        );
    }

    function _goldenConfig()
        internal
        pure
        returns (HellboxPublication.ReleaseConfig memory config)
    {
        config.publicationKey = "hellbox-native-001";
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

    function _goldenCommitments()
        internal
        pure
        returns (HellboxPublication.CommitmentSet memory commitments)
    {
        commitments.publicationManifestDigest =
            keccak256("publication-manifest-v1");
        commitments.packageDigest =
            keccak256("package-v1");
        commitments.fixedCopyRulesDigest =
            keccak256("fixed-copy-rules-v1");
        commitments.birthTraitsDigest =
            keccak256("birth-traits-v1");
        commitments.randomizationPolicyDigest =
            keccak256("randomization-policy-v1");
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

    function _releaseDigest(
        uint256 chainId,
        address factoryAddress,
        HellboxPublication.ReleaseConfig memory config,
        HellboxPublication.CommitmentSet memory commitments
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EXPECTED_RELEASE_CONFIG_DOMAIN,
                    uint256(1),
                    uint256(1),
                    uint256(1),
                    EXPECTED_TEMPLATE_ID,
                    chainId,
                    factoryAddress,
                    config,
                    commitments
                )
            );
    }
}
