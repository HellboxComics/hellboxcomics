// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxPublicationFactory} from "../contracts/HellboxPublicationFactory.sol";
import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";
import {HellboxPrimarySale} from "../contracts/HellboxPrimarySale.sol";
import {HellboxArtDataStore} from "../contracts/HellboxArtDataStore.sol";
import {HellboxNativeRendererV1} from "../contracts/HellboxNativeRendererV1.sol";

/// @notice The exact SciVive release configuration intended for PulseChain
///         Testnet V4, proven locally before any gas is spent.
/// @dev Existing suites cover the SciVive *shape* with test randomness values,
///      and the production drand policy with the native-216 shape. Nothing
///      covered both. A SciVive release carrying test randomness values would
///      publish and then fail to bind the real verifier, and that failure would
///      have been discovered on-chain. This suite closes that gap.
///
///      Commitment digests here are deliberately labelled proving placeholders.
///      Real manifest, package, reader, pricing and metadata digests require the
///      content package that Gate 6 builds. Nothing in this configuration should
///      be mistaken for a finished public release.
contract HellboxSciViveReleaseTest {
    /// @notice Hellbox project wallet: factory authority and royalty receiver.
    address internal constant PROJECT_WALLET = 0xD968A09e2B065FD6d7DF05DC9c5a657F281e565a;

    /// @dev The frozen production drand evmnet provider configuration. This is
    ///      the value the deployed verifier reports; a release that does not
    ///      commit to it will not bind that verifier.
    bytes32 internal constant DRAND_PROVIDER_CONFIG_DIGEST =
        0x0d191efbb2f605bf73b6f3c4819b21bc8c7a64393c6dcfd43b6b2f6b5be401e3;

    bytes32 internal constant RELEASE_CONFIG_DOMAIN = keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");
    bytes32 internal constant TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION");

    uint256 internal constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 internal constant CONFIG_SCHEMA_VERSION = 1;
    uint256 internal constant PUBLICATION_VERSION = 1;

    uint256 internal constant SCIVIVE_SUPPLY = 5_555;

    // Book/ebook page trim, distinct from the native comic canvas (which stays
    // at 1988x3056). SciVive is a plain paged book, not a comic.
    uint256 internal constant CANVAS_WIDTH = 1600;
    uint256 internal constant CANVAS_HEIGHT = 2560;

    /// @dev Proving plate, not finished cover art. It also uses a generic font
    ///      family, which the blueprint forbids for a canonical release cover:
    ///      Gate 6 must convert type to outlines so reconstruction never depends
    ///      on a font installed on the viewer's device.
    bytes internal constant SCIVIVE_PLATE = bytes(
        '<rect width="1600" height="2560" fill="#0b0b0f"/>'
        '<rect x="88" y="88" width="1424" height="2384" fill="none" stroke="#f05a22" stroke-width="8"/>'
        '<text x="800" y="1280" fill="#f2f2f2" font-family="monospace" font-size="150" text-anchor="middle">SCIVIVE</text>'
        '<text x="800" y="1460" fill="#8b48ff" font-family="monospace" font-size="52" text-anchor="middle">TESTNET PROVING PLATE</text>'
    );

    struct Release {
        HellboxPublicationFactory factory;
        HellboxPublication publication;
        address artDataStore;
        address renderer;
    }

    function testSciViveReleaseBindsTheProductionRandomnessVerifier() public {
        Release memory release = _publishSciVive();

        // The exact binding that a wrong randomization policy would break.
        require(
            release.publication.randomnessVerifier() == release.factory.randomnessVerifier(),
            "verifier not bound"
        );
        require(
            release.publication.randomnessVerifierRuntimeCodeHash()
                == release.factory.randomnessVerifierRuntimeCodeHash(),
            "verifier code hash"
        );
        require(
            release.publication.randomnessProviderConfigDigest() == DRAND_PROVIDER_CONFIG_DIGEST,
            "not the production drand provider"
        );
    }

    function testSciViveReleaseIsOfficialAndBootstrapped() public {
        Release memory release = _publishSciVive();

        require(release.factory.isPublication(address(release.publication)), "official provenance");
        require(release.publication.factory() == address(release.factory), "factory binding");
        require(release.publication.maxSupply() == SCIVIVE_SUPPLY, "supply");
        require(release.publication.issuanceStateInitialized(), "issuance bootstrap");
        require(release.publication.candidatePoolRemaining() == SCIVIVE_SUPPLY, "candidate pool");
        require(release.publication.nonTailIssuanceRemaining() == SCIVIVE_SUPPLY, "non-tail pool");
    }

    function testSciViveCarriesNoNativeSixTailOrTimer() public {
        Release memory release = _publishSciVive();

        require(release.publication.immediateCreatorCount() == 0, "no creator six");
        require(release.publication.tailReserveCount() == 0, "no tail reserve");
        require(release.publication.primaryLifetimeCap() == 1, "one per wallet");
        // SciVive is the free proving exception and inherits no native timer.
        require(release.publication.nativeMintDeadline() == 0, "scivive must stay untimed");
    }

    function testSciViveRendererIsBoundToTheFrozenCommitment() public {
        Release memory release = _publishSciVive();

        require(
            release.factory.rendererByPublication(address(release.publication)) == release.renderer,
            "renderer not bound"
        );
        require(
            release.factory.publicationByRenderer(release.renderer) == address(release.publication),
            "reverse lookup"
        );

        HellboxNativeRendererV1 renderer = HellboxNativeRendererV1(release.renderer);
        require(renderer.artDataStore() == release.artDataStore, "art store");
        require(renderer.canvasWidth() == CANVAS_WIDTH, "canvas width");
        require(renderer.canvasHeight() == CANVAS_HEIGHT, "canvas height");
    }

    function testSciViveRendersSelfContainedMetadataWithoutTraits() public {
        Release memory release = _publishSciVive();

        string memory uri =
            HellboxNativeRendererV1(release.renderer).tokenURI(address(release.publication), 1);

        require(_hasJsonDataUriPrefix(uri), "self-contained json data uri");

        // Trait-disabled release: the plate renders, no MARK/DEFECT is invented.
        HellboxBirthPolicy policy = HellboxBirthPolicy(release.publication.birthPolicy());
        require(!policy.birthIdentityAssigned(1), "no birth identity before issuance");
    }

    function testSciVivePlateRoundTripsOutOfImmutableStorage() public {
        Release memory release = _publishSciVive();

        bytes memory recovered = HellboxNativeRendererV1(release.renderer).plateBytes();
        require(keccak256(recovered) == keccak256(SCIVIVE_PLATE), "plate bytes");
    }

    // ---------------------------------------------------------------------
    // The deployable configuration itself
    // ---------------------------------------------------------------------

    function _publishSciVive() internal returns (Release memory release) {
        HellboxBirthPolicyCodeStore codeStore = new HellboxBirthPolicyCodeStore();

        release.factory = new HellboxPublicationFactory(
            address(this),
            keccak256(type(HellboxPublication).creationCode),
            keccak256(type(HellboxPrimarySale).creationCode),
            address(codeStore),
            keccak256(type(HellboxBirthPolicy).creationCode)
        );

        release.artDataStore = address(new HellboxArtDataStore(SCIVIVE_PLATE, keccak256(SCIVIVE_PLATE)));

        HellboxPublication.ReleaseConfig memory config = _sciViveConfig();
        HellboxPublication.CommitmentSet memory commitments = _sciViveCommitments(
            release.factory.rendererRulesDigest(_rendererPreimages(release.artDataStore))
        );

        release.publication = HellboxPublication(
            release.factory.publish(
                config,
                commitments,
                _releaseDigest(block.chainid, address(release.factory), config, commitments),
                _birthPolicyPreimages(),
                type(HellboxPublication).creationCode
            )
        );

        release.renderer = release.factory.deployRenderer(
            address(release.publication),
            commitments,
            _rendererPreimages(release.artDataStore),
            type(HellboxNativeRendererV1).creationCode,
            abi.encode(
                release.artDataStore,
                release.artDataStore.codehash,
                CANVAS_WIDTH,
                CANVAS_HEIGHT
            )
        );
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
        // No fixed copies: SciVive has no creator six and no reserved grail.
        fixedPolicy.enabled = false;
        fixedPolicy.rules = new HellboxPublication.FixedCopyRuleEnforcement[](0);

        // Trait-disabled: no PRESS MARK, no PRESS DEFECT.
        birthTraits.enabled = false;
        birthTraits.axes = new HellboxPublication.BirthTraitAxisEnforcement[](0);

        // Production drand policy, identical to the native-216 profile except
        // for the trait-pool fields, which are unconstrained when both trait
        // axes are disabled.
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

        // Everything below is a labelled proving placeholder. Real values
        // require the Gate 6 content package.
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

    function _hasJsonDataUriPrefix(string memory value) internal pure returns (bool) {
        bytes memory raw = bytes(value);
        bytes memory prefix = bytes("data:application/json;base64,");
        if (raw.length < prefix.length) {
            return false;
        }
        for (uint256 i; i < prefix.length; ++i) {
            if (raw[i] != prefix[i]) {
                return false;
            }
        }
        return true;
    }
}
