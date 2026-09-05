// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Script, console2} from "forge-std/Script.sol";
import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxPublicationFactory} from "../contracts/HellboxPublicationFactory.sol";
import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";
import {HellboxPrimarySale} from "../contracts/HellboxPrimarySale.sol";
import {HellboxArtDataStore} from "../contracts/HellboxArtDataStore.sol";
import {HellboxNativeRendererV1} from "../contracts/HellboxNativeRendererV1.sol";

/// @notice Deploys the exact SciVive release configuration proven in
///         test/HellboxSciViveRelease.t.sol to PulseChain Testnet V4 (chain 943).
/// @dev Every constant and helper below is copied verbatim from the proving
///      test so the deployed release is provably identical to what 217 tests
///      already passed against. Do not hand-tune a value here without first
///      changing it in the test and re-running that suite green.
///
///      The broadcasting account becomes the factory/publication owner for
///      this run (msg.sender), because publish() and deployRenderer() are
///      onlyOwner and must be called by the same account that deploys the
///      factory, in the same script. If you deployed with the project
///      wallet's own key, msg.sender already equals PROJECT_WALLET and
///      nothing further is needed. If you used a separate throwaway
///      deployer key, run the ownership rotation this script prints at the
///      end: factory.transferOwnership(PROJECT_WALLET) from the deployer,
///      then factory.acceptOwnership() from the project wallet.
contract DeploySciViveTestnet is Script {
    address internal constant PROJECT_WALLET = 0xD968A09e2B065FD6d7DF05DC9c5a657F281e565a;

    bytes32 internal constant DRAND_PROVIDER_CONFIG_DIGEST =
        0x0d191efbb2f605bf73b6f3c4819b21bc8c7a64393c6dcfd43b6b2f6b5be401e3;

    bytes32 internal constant RELEASE_CONFIG_DOMAIN = keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");
    bytes32 internal constant TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION");

    uint256 internal constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 internal constant CONFIG_SCHEMA_VERSION = 1;
    uint256 internal constant PUBLICATION_VERSION = 1;

    uint256 internal constant SCIVIVE_SUPPLY = 5_555;

    // Book/ebook page trim, matching the proving test. Distinct from the
    // native comic canvas, which stays at 1988x3056.
    uint256 internal constant CANVAS_WIDTH = 1600;
    uint256 internal constant CANVAS_HEIGHT = 2560;

    /// @dev Proving plate, not finished cover art. Gate 6 must replace this
    ///      with real cover art (type converted to outlines) before mainnet.
    bytes internal constant SCIVIVE_PLATE = bytes(
        '<rect width="1600" height="2560" fill="#0b0b0f"/>'
        '<rect x="88" y="88" width="1424" height="2384" fill="none" stroke="#f05a22" stroke-width="8"/>'
        '<text x="800" y="1280" fill="#f2f2f2" font-family="monospace" font-size="150" text-anchor="middle">SCIVIVE</text>'
        '<text x="800" y="1460" fill="#8b48ff" font-family="monospace" font-size="52" text-anchor="middle">TESTNET PROVING PLATE</text>'
    );

    function run() external {
        vm.startBroadcast();
        // NOTE: do NOT use msg.sender here. vm.startBroadcast() rewrites the
        // sender of subsequent CALL/CREATE ops, but msg.sender as read inside
        // this function body is still whoever invoked run() (Foundry's
        // DefaultSender during a plain simulation), not the --account signer.
        // hellbox-deployer's keystore address IS the project wallet, so we
        // hardcode it as the intended owner/deployer directly.
        address deployer = PROJECT_WALLET;

        HellboxBirthPolicyCodeStore codeStore = new HellboxBirthPolicyCodeStore();

        HellboxPublicationFactory factory = new HellboxPublicationFactory(
            deployer,
            keccak256(type(HellboxPublication).creationCode),
            keccak256(type(HellboxPrimarySale).creationCode),
            address(codeStore),
            keccak256(type(HellboxBirthPolicy).creationCode)
        );

        address artDataStore = address(new HellboxArtDataStore(SCIVIVE_PLATE, keccak256(SCIVIVE_PLATE)));

        HellboxPublication.ReleaseConfig memory config = _sciViveConfig();
        HellboxPublicationFactory.RendererPreimages memory rendererPreimages = _rendererPreimages(artDataStore);
        HellboxPublication.CommitmentSet memory commitments =
            _sciViveCommitments(factory.rendererRulesDigest(rendererPreimages));

        address publication = factory.publish(
            config,
            commitments,
            _releaseDigest(block.chainid, address(factory), config, commitments),
            _birthPolicyPreimages(),
            type(HellboxPublication).creationCode
        );

        address renderer = factory.deployRenderer(
            publication,
            commitments,
            rendererPreimages,
            type(HellboxNativeRendererV1).creationCode,
            abi.encode(artDataStore, artDataStore.codehash, CANVAS_WIDTH, CANVAS_HEIGHT)
        );

        vm.stopBroadcast();

        console2.log("=== SciVive testnet release deployed ===");
        console2.log("HellboxBirthPolicyCodeStore:", address(codeStore));
        console2.log("HellboxPublicationFactory:  ", address(factory));
        console2.log("HellboxArtDataStore:        ", artDataStore);
        console2.log("SciVive publication:        ", publication);
        console2.log("SciVive renderer:           ", renderer);
        console2.log("Owner (broadcasting account):", deployer);
        if (deployer != PROJECT_WALLET) {
            console2.log("");
            console2.log("Deployer is NOT the project wallet. Two-step ownership rotation needed:");
            console2.log("1) From the deployer account, call transferOwnership(newOwner) on the factory:");
            console2.log("   factory:", address(factory));
            console2.log("   newOwner (project wallet):", PROJECT_WALLET);
            console2.log("2) From the project wallet account, call acceptOwnership() on that same factory address.");
        }
    }

    function _sciViveConfig() internal pure returns (HellboxPublication.ReleaseConfig memory config) {
        config.publicationKey = "scivive";
        config.collectionName = "SciVive";
        config.collectionSymbol = "SCIVIVE";

        config.maxSupply = SCIVIVE_SUPPLY;
        config.primaryLifetimeCap = 1;
        config.maxPerTransaction = 1;

        config.immediateCreatorRecipient = address(0);
        config.immediateCreatorCount = 0;

        config.tailRecipient = address(0);
        config.tailReserveCount = 0;

        config.royaltyReceiver = PROJECT_WALLET;
        config.royaltyBps = 369;

        config.publisherAuthority = PROJECT_WALLET;

        config.readerEnabled = true;
        config.sealEnabled = true;
        config.archiveCompatible = false;
        config.dynamicMetadataEnabled = true;
        config.erc6551Compatible = true;
        config.rewardsCompatible = false;
        config.hellforgeCompatible = false;
        config.contextualTraitsEnabled = false;
    }

    function _sciVivePolicies()
        internal
        pure
        returns (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthTraits,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        )
    {
        fixedPolicy.enabled = false;
        fixedPolicy.rules = new HellboxPublication.FixedCopyRuleEnforcement[](0);

        birthTraits.enabled = false;
        birthTraits.axes = new HellboxPublication.BirthTraitAxisEnforcement[](0);

        randomPolicy.enabled = true;
        randomPolicy.policyId = keccak256("HELLBOX_DRAND_FIFO_RANDOMIZATION_V1");
        randomPolicy.schemeVersion = 1;
        randomPolicy.providerConfigDigest = DRAND_PROVIDER_CONFIG_DIGEST;
        randomPolicy.copyShuffleMode = keccak256("RANDOM_NON_SEQUENTIAL");
        randomPolicy.fixedIdExclusionsDigest = _fixedDigest(fixedPolicy);
        randomPolicy.traitPoolMode = bytes32(0);
        randomPolicy.markDefectIndependent = false;
        randomPolicy.creatorDefectFairness = bytes32(0);
        randomPolicy.publisherMapKnowledgePolicy = keccak256("NO_FULL_PREKNOWN_MAP");
        randomPolicy.assignmentProofMode = keccak256("DRAND_ROUND_REQUEST_EVENT_V1");
    }

    function _sciViveCommitments(bytes32 frozenRendererRulesDigest)
        internal
        pure
        returns (HellboxPublication.CommitmentSet memory commitments)
    {
        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthTraits,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _sciVivePolicies();

        commitments.fixedCopyRulesDigest = _fixedDigest(fixedPolicy);
        commitments.birthTraitsDigest = _birthDigest(birthTraits);
        commitments.randomizationPolicyDigest = _randomDigest(randomPolicy);
        commitments.rendererRulesDigest = frozenRendererRulesDigest;

        // Labelled proving placeholders. Real values require the Gate 6
        // content package; do not mistake this for a finished public release.
        commitments.publicationManifestDigest = keccak256("SCIVIVE_TESTNET_PROVING_MANIFEST");
        commitments.packageDigest = keccak256("SCIVIVE_TESTNET_PROVING_PACKAGE");
        commitments.readerPolicyDigest = keccak256("SCIVIVE_TESTNET_PROVING_READER_POLICY");
        commitments.pricingPoliciesDigest = keccak256("SCIVIVE_TESTNET_PROVING_PRICING");
        commitments.paymentRoutesDigest = keccak256("SCIVIVE_TESTNET_PROVING_PAYMENT_ROUTES");
        commitments.mintPhasesDigest = keccak256("SCIVIVE_TESTNET_PROVING_MINT_PHASES");
        commitments.royaltyPolicyDigest = keccak256("SCIVIVE_TESTNET_PROVING_ROYALTY");
        commitments.treasuryPolicyDigest = keccak256("SCIVIVE_TESTNET_PROVING_TREASURY");
        commitments.metadataPolicyDigest = keccak256("SCIVIVE_TESTNET_PROVING_METADATA");
        commitments.capabilityPolicyDigest = keccak256("SCIVIVE_TESTNET_PROVING_CAPABILITY");
        commitments.protocolCompatibilityDigest = keccak256("SCIVIVE_TESTNET_PROVING_PROTOCOL");
        commitments.closurePolicyDigest = keccak256("SCIVIVE_TESTNET_PROVING_CLOSURE");
        commitments.authorityPolicyDigest = keccak256("SCIVIVE_TESTNET_PROVING_AUTHORITY");
        commitments.eventPolicyDigest = keccak256("SCIVIVE_TESTNET_PROVING_EVENT_POLICY");
    }

    function _birthPolicyPreimages()
        internal
        pure
        returns (HellboxPublicationFactory.BirthPolicyPreimages memory preimages)
    {
        (
            HellboxPublication.FixedCopyRulesEnforcement memory fixedPolicy,
            HellboxPublication.BirthTraitsEnforcement memory birthTraits,
            HellboxPublication.RandomizationPolicyEnforcement memory randomPolicy
        ) = _sciVivePolicies();

        preimages.fixedCopyPolicyPreimage = abi.encode(fixedPolicy);
        preimages.birthTraitsPolicyPreimage = abi.encode(birthTraits);
        preimages.randomizationPolicyPreimage = abi.encode(randomPolicy);
    }

    function _rendererPreimages(address store)
        internal
        view
        returns (HellboxPublicationFactory.RendererPreimages memory preimages)
    {
        preimages = HellboxPublicationFactory.RendererPreimages({
            rendererId: keccak256("HELLBOX_NATIVE_RENDERER"),
            rendererVersion: 1,
            interfaceVersion: 1,
            rendererCreationCodeHash: keccak256(type(HellboxNativeRendererV1).creationCode),
            artDataStore: store,
            artDataStoreCodeHash: store.codehash,
            canvasWidth: CANVAS_WIDTH,
            canvasHeight: CANVAS_HEIGHT
        });
    }

    function _fixedDigest(HellboxPublication.FixedCopyRulesEnforcement memory policy)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(keccak256("HELLBOX_ENFORCEMENT_V1:FIXED_COPY_RULES"), policy));
    }

    function _birthDigest(HellboxPublication.BirthTraitsEnforcement memory policy)
        internal
        pure
        returns (bytes32)
    {
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
}
