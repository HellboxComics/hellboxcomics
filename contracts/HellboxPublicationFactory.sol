// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

import {HellboxPublication} from "./HellboxPublication.sol";

/// @title HellboxPublicationFactory
/// @notice Gate 4 V1 factory for manufacturing official full-deployment
///         HellboxPublication collections from frozen release configuration.
/// @dev Authenticity is rooted outside this contract by Hellbox recognizing this
///      factory address as an approved factory for the target chain/version.
///      This factory proves only what it physically deployed.
contract HellboxPublicationFactory is Ownable2Step {
    // ---------------------------------------------------------------------
    // Version / architecture identity
    // ---------------------------------------------------------------------

    uint256 public constant FACTORY_VERSION = 1;
    uint256 public constant PUBLICATION_VERSION = 1;

    bytes32 public constant TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION");
    bytes32 public constant DEPLOYMENT_MODE = keccak256("FULL_DEPLOYMENT");

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

    error OwnershipRenunciationDisabled();

    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------

    /// @notice Permanent provenance event for a publication physically created
    ///         by this approved factory.
    /// @dev Block number, timestamp, transaction, and log position are already
    ///      inherent in the chain and are intentionally not duplicated in state.
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
    constructor(
        address initialPublisherAuthority
    ) Ownable(initialPublisherAuthority) {}

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
    /// @dev V1 deliberately uses ordinary CREATE via `new`, not CREATE2, clones,
    ///      proxies, initializers, delegatecall, or an upgrade mechanism.
    ///
    ///      The expected release digest must already have been computed against
    ///      this factory address and the current chain ID. HellboxPublication
    ///      independently recomputes and verifies that digest in its constructor.
    function publish(
        HellboxPublication.ReleaseConfig calldata config,
        HellboxPublication.CommitmentSet calldata commitments,
        bytes32 expectedReleaseConfigDigest
    ) external onlyOwner returns (address publicationAddress) {
        bytes32 publicationKeyHash = keccak256(bytes(config.publicationKey));

        address existingByKey = publicationByKeyHash[publicationKeyHash];
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

        HellboxPublication.ReleaseConfig memory config_ = config;
        HellboxPublication.CommitmentSet memory commitments_ = commitments;

        HellboxPublication publication = new HellboxPublication(
            config_,
            commitments_,
            expectedReleaseConfigDigest
        );

        _verifyDeployment(
            publication,
            publicationKeyHash,
            expectedReleaseConfigDigest
        );

        publicationAddress = address(publication);
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
    }
}
