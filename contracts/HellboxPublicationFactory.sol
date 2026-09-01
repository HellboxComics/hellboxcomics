// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {HellboxPublication} from "./HellboxPublication.sol";
import {HellboxBirthPolicy} from "./HellboxBirthPolicy.sol";

/// @title HellboxPublicationFactory
/// @notice Gate 4 V1 factory for manufacturing official full-deployment
///         HellboxPublication collections from frozen release configuration.
/// @dev Authenticity is rooted outside this contract by Hellbox recognizing this
///      factory address as an approved factory for the target chain/version.
///
///      V1 uses ordinary CREATE and exact approved HellboxPublication creation
///      bytecode supplied at publish time. The creation code is hash-bound to
///      this factory generation instead of being embedded in factory runtime.
///
///      This remains FULL_DEPLOYMENT. There is no CREATE2, clone, proxy,
///      initializer, delegatecall, implementation registry, or upgrade path.
contract HellboxPublicationFactory is Ownable2Step {
    // ---------------------------------------------------------------------
    // Version / architecture identity
    // ---------------------------------------------------------------------

    uint256 public constant FACTORY_VERSION = 1;
    uint256 public constant PUBLICATION_VERSION = 1;

    bytes32 public constant TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION");
    bytes32 public constant DEPLOYMENT_MODE = keccak256("FULL_DEPLOYMENT");

    /// @notice Exact creation-code hash approved for this factory generation.
    /// @dev Registry/factory provenance only. This is not a ReleaseConfig field,
    ///      does not change HELLBOX_ABI_V1, and is not a universal instance
    ///      runtime hash.
    bytes32 public immutable approvedPublicationCreationCodeHash;

    /// @notice Inert HellboxBirthPolicyCodeStore selected for this factory
    ///         generation.
    /// @dev Factory-generation provenance only. Publications will copy the
    ///      stored BirthPolicy creation bytes from runtime offset 1 and verify
    ///      them against `approvedBirthPolicyCreationCodeHash` before CREATE.
    ///      This is never caller-selected per publication.
    address public immutable birthPolicyCodeStore;

    /// @notice Exact keccak256 of the HellboxBirthPolicy creation bytes stored
    ///         after runtime offset 1 in `birthPolicyCodeStore`.
    /// @dev Factory-generation provenance only. This does not enter
    ///      ReleaseConfig and does not change HELLBOX_ABI_V1.
    bytes32 public immutable approvedBirthPolicyCreationCodeHash;

    /// @notice Narrow publish-time transport for the three committed
    ///         BirthPolicy enforcement preimages.
    /// @dev This struct intentionally excludes the code-store address/hash,
    ///      which remain immutable factory-generation provenance.
    struct BirthPolicyPreimages {
        bytes fixedCopyPolicyPreimage;
        bytes birthTraitsPolicyPreimage;
        bytes randomizationPolicyPreimage;
    }

    // ---------------------------------------------------------------------
    // Minimal append-only provenance state
    // ---------------------------------------------------------------------

    mapping(address publication => bool) public isPublication;

    mapping(bytes32 releaseConfigDigest => address publication)
        public publicationByReleaseDigest;

    mapping(bytes32 publicationKeyHash => address publication)
        public publicationByKeyHash;

    address[] public publications;

    // ---------------------------------------------------------------------
    // Errors
    // ---------------------------------------------------------------------

    error InvalidApprovedPublicationCreationCodeHash();

    error InvalidBirthPolicyCodeStore();

    error InvalidApprovedBirthPolicyCreationCodeHash();

    error UnapprovedPublicationCreationCode(
        bytes32 expectedCreationCodeHash,
        bytes32 actualCreationCodeHash
    );

    error DuplicateReleaseConfigDigest(
        bytes32 releaseConfigDigest,
        address existingPublication
    );

    error DuplicatePublicationKey(
        bytes32 publicationKeyHash,
        address existingPublication
    );

    error DeploymentFactoryMismatch(address expected, address actual);

    error DeploymentChainMismatch(uint256 expected, uint256 actual);

    error DeploymentTemplateMismatch(bytes32 expected, bytes32 actual);

    error DeploymentPublicationVersionMismatch(
        uint256 expected,
        uint256 actual
    );

    error DeploymentReleaseDigestMismatch(bytes32 expected, bytes32 actual);

    error DeploymentPublicationKeyMismatch(bytes32 expected, bytes32 actual);

    error DeploymentBirthPolicyMissing();
    error DeploymentBirthPolicyPublicationMismatch(
        address expected,
        address actual
    );

    error OwnershipRenunciationDisabled();

    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------

    /// @notice Permanent provenance event for a publication physically created
    ///         by this approved factory.
    /// @dev Block number, timestamp, transaction, and log position are already
    ///      inherent in the chain and are intentionally not duplicated in state.
    ///
    ///      `publisherAuthority` here is the factory publishing authority
    ///      observed for this deployment, not the publication-level operational
    ///      authority stored in HellboxPublication.ReleaseConfig.
    event PublicationPublished(
        address indexed publication,
        bytes32 indexed releaseConfigDigest,
        bytes32 indexed publicationKeyHash,
        address publisherAuthority,
        bytes32 runtimeCodeHash
    );

    // ---------------------------------------------------------------------
    // Construction / authority
    // ---------------------------------------------------------------------

    /// @param initialPublisherAuthority Initial authority allowed to publish new
    ///        Hellbox collections through this factory. This may later rotate
    ///        through Ownable2Step, including to a Safe or other controller.
    /// @param publicationCreationCodeHash keccak256 of the exact reviewed
    ///        HellboxPublication V1 creation bytecode approved for this factory
    ///        generation.
    /// @param birthPolicyCodeStoreAddress Inert HellboxBirthPolicyCodeStore
    ///        selected for this factory generation. It is intentionally frozen
    ///        here rather than accepted from `publish(...)`.
    /// @param birthPolicyCreationCodeHash keccak256 of the exact
    ///        HellboxBirthPolicy creation bytes stored after runtime offset 1
    ///        in the selected code store.
    constructor(
        address initialPublisherAuthority,
        bytes32 publicationCreationCodeHash,
        address birthPolicyCodeStoreAddress,
        bytes32 birthPolicyCreationCodeHash
    ) Ownable(initialPublisherAuthority) {
        if (publicationCreationCodeHash == bytes32(0)) {
            revert InvalidApprovedPublicationCreationCodeHash();
        }

        if (birthPolicyCodeStoreAddress == address(0)) {
            revert InvalidBirthPolicyCodeStore();
        }

        if (birthPolicyCreationCodeHash == bytes32(0)) {
            revert InvalidApprovedBirthPolicyCreationCodeHash();
        }

        approvedPublicationCreationCodeHash = publicationCreationCodeHash;
        birthPolicyCodeStore = birthPolicyCodeStoreAddress;
        approvedBirthPolicyCreationCodeHash =
            birthPolicyCreationCodeHash;
    }

    /// @notice Ownership renunciation is intentionally disabled so the official
    ///         V1 factory cannot be permanently bricked by an accidental call.
    /// @dev Factory authority may still rotate normally through Ownable2Step.
    function renounceOwnership() public override onlyOwner {
        revert OwnershipRenunciationDisabled();
    }

    // ---------------------------------------------------------------------
    // Publication deployment
    // ---------------------------------------------------------------------

    /// @notice Deploys one new HellboxPublication V1 collection from an already
    ///         frozen HELLBOX_ABI_V1 release configuration.
    ///
    /// @dev V1 deliberately uses ordinary CREATE with exact hash-approved
    ///      creation bytecode, not CREATE2, clones, proxies, initializers,
    ///      delegatecall, an implementation registry, or an upgrade mechanism.
    ///
    ///      Keeping publication creation code out of this factory's runtime
    ///      prevents HellboxPublication growth from making the factory itself
    ///      undeployable under EIP-170.
    ///
    ///      The expected release digest must already have been computed against
    ///      this factory address and the current chain ID. HellboxPublication
    ///      independently recomputes and verifies that digest in its constructor.
    ///      The three enforcement preimages are narrow constructor transport only;
    ///      the factory-owned code-store address/hash remain generation immutables.
    function publish(
        HellboxPublication.ReleaseConfig calldata config,
        HellboxPublication.CommitmentSet calldata commitments,
        bytes32 expectedReleaseConfigDigest,
        BirthPolicyPreimages calldata birthPolicyPreimages,
        bytes calldata publicationCreationCode
    ) external onlyOwner returns (address publicationAddress) {
        bytes32 publicationKeyHash = keccak256(bytes(config.publicationKey));

        _rejectDuplicatePublication(
            publicationKeyHash,
            expectedReleaseConfigDigest
        );

        bytes memory creationCode = publicationCreationCode;
        bytes32 actualCreationCodeHash = keccak256(creationCode);

        if (
            actualCreationCodeHash !=
            approvedPublicationCreationCodeHash
        ) {
            revert UnapprovedPublicationCreationCode(
                approvedPublicationCreationCodeHash,
                actualCreationCodeHash
            );
        }

        publicationAddress = _deployPublication(
            creationCode,
            config,
            commitments,
            expectedReleaseConfigDigest,
            birthPolicyPreimages
        );

        HellboxPublication publication =
            HellboxPublication(publicationAddress);

        _verifyDeployment(
            publication,
            publicationKeyHash,
            expectedReleaseConfigDigest
        );

        bytes32 runtimeCodeHash = publicationAddress.codehash;

        // Provenance becomes official only after all defensive checks pass.
        isPublication[publicationAddress] = true;

        publicationByReleaseDigest[
            expectedReleaseConfigDigest
        ] = publicationAddress;

        publicationByKeyHash[publicationKeyHash] = publicationAddress;

        publications.push(publicationAddress);

        emit PublicationPublished(
            publicationAddress,
            expectedReleaseConfigDigest,
            publicationKeyHash,
            owner(),
            runtimeCodeHash
        );
    }

    /// @notice Number of publications physically deployed and accepted by this
    ///         factory.
    function publicationCount() external view returns (uint256) {
        return publications.length;
    }

    // ---------------------------------------------------------------------
    // Deployment helpers
    // ---------------------------------------------------------------------

    function _rejectDuplicatePublication(
        bytes32 publicationKeyHash,
        bytes32 expectedReleaseConfigDigest
    ) internal view {
        address existingByKey =
            publicationByKeyHash[publicationKeyHash];

        if (existingByKey != address(0)) {
            revert DuplicatePublicationKey(
                publicationKeyHash,
                existingByKey
            );
        }

        address existingByDigest =
            publicationByReleaseDigest[expectedReleaseConfigDigest];

        if (existingByDigest != address(0)) {
            revert DuplicateReleaseConfigDigest(
                expectedReleaseConfigDigest,
                existingByDigest
            );
        }
    }

    /// @dev Reconstructs exactly the initcode Solidity would use for a normal
    ///      full deployment: reviewed creation bytecode followed by standard ABI
    ///      constructor arguments. CREATE executes from this factory, so the
    ///      publication constructor still records `msg.sender` as the factory.
    function _deployPublication(
        bytes memory creationCode,
        HellboxPublication.ReleaseConfig calldata config,
        HellboxPublication.CommitmentSet calldata commitments,
        bytes32 expectedReleaseConfigDigest,
        BirthPolicyPreimages calldata birthPolicyPreimages
    ) internal returns (address publicationAddress) {
        HellboxPublication.BirthPolicyDeploymentContext memory
            birthPolicyContext = HellboxPublication.BirthPolicyDeploymentContext({
                codeStore: birthPolicyCodeStore,
                approvedCreationCodeHash:
                    approvedBirthPolicyCreationCodeHash,
                fixedCopyPolicyPreimage:
                    birthPolicyPreimages.fixedCopyPolicyPreimage,
                birthTraitsPolicyPreimage:
                    birthPolicyPreimages.birthTraitsPolicyPreimage,
                randomizationPolicyPreimage:
                    birthPolicyPreimages.randomizationPolicyPreimage
            });

        bytes memory constructorArguments = abi.encode(
            config,
            commitments,
            expectedReleaseConfigDigest,
            birthPolicyContext
        );

        bytes memory initCode = bytes.concat(
            creationCode,
            constructorArguments
        );

        assembly ("memory-safe") {
            publicationAddress := create(
                0,
                add(initCode, 0x20),
                mload(initCode)
            )

            if iszero(publicationAddress) {
                let size := returndatasize()
                returndatacopy(0, 0, size)
                revert(0, size)
            }
        }
    }

    // ---------------------------------------------------------------------
    // Defensive provenance verification
    // ---------------------------------------------------------------------

    function _verifyDeployment(
        HellboxPublication publication,
        bytes32 expectedPublicationKeyHash,
        bytes32 expectedReleaseConfigDigest
    ) internal view {
        address reportedFactory = publication.factory();

        if (reportedFactory != address(this)) {
            revert DeploymentFactoryMismatch(
                address(this),
                reportedFactory
            );
        }

        uint256 reportedChainId = publication.releaseChainId();

        if (reportedChainId != block.chainid) {
            revert DeploymentChainMismatch(
                block.chainid,
                reportedChainId
            );
        }

        bytes32 reportedTemplateId = publication.TEMPLATE_ID();

        if (reportedTemplateId != TEMPLATE_ID) {
            revert DeploymentTemplateMismatch(
                TEMPLATE_ID,
                reportedTemplateId
            );
        }

        uint256 reportedPublicationVersion =
            publication.PUBLICATION_VERSION();

        if (reportedPublicationVersion != PUBLICATION_VERSION) {
            revert DeploymentPublicationVersionMismatch(
                PUBLICATION_VERSION,
                reportedPublicationVersion
            );
        }

        bytes32 reportedReleaseConfigDigest =
            publication.releaseConfigDigest();

        if (
            reportedReleaseConfigDigest !=
            expectedReleaseConfigDigest
        ) {
            revert DeploymentReleaseDigestMismatch(
                expectedReleaseConfigDigest,
                reportedReleaseConfigDigest
            );
        }

        bytes32 reportedPublicationKeyHash =
            keccak256(bytes(publication.publicationKey()));

        if (
            reportedPublicationKeyHash !=
            expectedPublicationKeyHash
        ) {
            revert DeploymentPublicationKeyMismatch(
                expectedPublicationKeyHash,
                reportedPublicationKeyHash
            );
        }

        address reportedBirthPolicy = publication.birthPolicy();
        if (
            reportedBirthPolicy == address(0) ||
            reportedBirthPolicy.code.length == 0
        ) {
            revert DeploymentBirthPolicyMissing();
        }

        address reportedBirthPolicyPublication =
            HellboxBirthPolicy(reportedBirthPolicy).publication();

        if (reportedBirthPolicyPublication != address(publication)) {
            revert DeploymentBirthPolicyPublicationMismatch(
                address(publication),
                reportedBirthPolicyPublication
            );
        }
    }
}
