// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Royalty} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Royalty.sol";

/// @title HellboxPublication
/// @notice Gate 4 V1 publication kernel: constructor-frozen release identity,
///         configuration commitments, ERC-721 ownership baseline, and ERC-2981 royalties.
/// @dev This is an implementation checkpoint, not yet the finished deployable Gate 4 publication.
///      Minting, phases, random assignment, tail execution, metadata rendering, and later protocols
///      are added to this same V1 kernel only after their required behavior is implemented and tested.
contract HellboxPublication is ERC721Royalty {
    // ---------------------------------------------------------------------
    // HELLBOX_ABI_V1 protocol constants
    // ---------------------------------------------------------------------

    uint256 public constant COMMITMENT_SCHEME_VERSION = 1;
    uint256 public constant CONFIG_SCHEMA_VERSION = 1;
    uint256 public constant PUBLICATION_VERSION = 1;

    bytes32 public constant TEMPLATE_ID = keccak256("HELLBOX_PUBLICATION");
    bytes32 public constant RELEASE_CONFIG_DOMAIN =
        keccak256("HELLBOX_ABI_V1:RELEASE_CONFIG");

    uint256 public constant TOKEN_ID_START = 1;

    // ---------------------------------------------------------------------
    // Frozen constructor configuration
    // ---------------------------------------------------------------------

    struct ReleaseConfig {
        string publicationKey;
        string collectionName;
        string collectionSymbol;

        uint256 maxSupply;
        uint256 primaryLifetimeCap;
        uint256 maxPerTransaction;

        address immediateCreatorRecipient;
        uint256 immediateCreatorCount;

        address tailRecipient;
        uint256 tailReserveCount;

        address royaltyReceiver;
        uint96 royaltyBps;

        address publisherAuthority;

        bool readerEnabled;
        bool sealEnabled;
        bool archiveCompatible;
        bool dynamicMetadataEnabled;
        bool erc6551Compatible;
        bool rewardsCompatible;
        bool hellforgeCompatible;
        bool contextualTraitsEnabled;
    }

    /// @notice Versioned sub-commitments covering rich release data kept outside
    ///         direct contract storage.
    /// @dev HELLBOX_ABI_V1 commits this exact field order. Do not reorder or
    ///      reinterpret these fields without a new commitment/config version.
    struct CommitmentSet {
        bytes32 publicationManifestDigest;
        bytes32 packageDigest;
        bytes32 fixedCopyRulesDigest;
        bytes32 birthTraitsDigest;
        bytes32 randomizationPolicyDigest;
        bytes32 rendererRulesDigest;
        bytes32 readerPolicyDigest;
        bytes32 pricingPoliciesDigest;
        bytes32 paymentRoutesDigest;
        bytes32 mintPhasesDigest;
        bytes32 royaltyPolicyDigest;
        bytes32 treasuryPolicyDigest;
        bytes32 metadataPolicyDigest;
        bytes32 capabilityPolicyDigest;
        bytes32 protocolCompatibilityDigest;
        bytes32 closurePolicyDigest;
        bytes32 authorityPolicyDigest;
        bytes32 eventPolicyDigest;
    }

    string public publicationKey;

    uint256 public immutable releaseChainId;
    address public immutable factory;

    uint256 public immutable maxSupply;
    uint256 public immutable primaryLifetimeCap;
    uint256 public immutable maxPerTransaction;

    address public immutable immediateCreatorRecipient;
    uint256 public immutable immediateCreatorCount;

    address public immutable tailRecipient;
    uint256 public immutable tailReserveCount;

    address public immutable royaltyReceiver;
    uint96 public immutable royaltyBps;

    address public immutable publisherAuthority;

    bool public immutable readerEnabled;
    bool public immutable sealEnabled;
    bool public immutable archiveCompatible;
    bool public immutable dynamicMetadataEnabled;
    bool public immutable erc6551Compatible;
    bool public immutable rewardsCompatible;
    bool public immutable hellforgeCompatible;
    bool public immutable contextualTraitsEnabled;

    bytes32 public immutable publicationManifestDigest;
    bytes32 public immutable packageDigest;
    bytes32 public immutable commitmentsDigest;
    bytes32 public immutable releaseConfigDigest;

    bool public immutable configFrozen;
    uint256 public immutable frozenAtBlock;
    uint256 public immutable frozenAtTimestamp;

    // ---------------------------------------------------------------------
    // Errors
    // ---------------------------------------------------------------------

    error InvalidPublicationKey();
    error InvalidCollectionNameLength(uint256 byteLength);
    error InvalidCollectionSymbol();
    error InvalidMaxSupply();
    error InvalidPrimaryLifetimeCap(uint256 cap, uint256 supply);
    error InvalidMaxPerTransaction(uint256 maxPerTransaction, uint256 lifetimeCap);
    error InvalidCreatorAllocation(
        uint256 immediateCreatorCount,
        uint256 tailReserveCount,
        uint256 supply
    );
    error InvalidImmediateCreatorRecipient();
    error InvalidTailRecipient();
    error InvalidRoyaltyConfiguration(address receiver, uint96 bps);
    error InvalidPublisherAuthority();
    error InvalidCapabilityConfiguration();
    error MissingRequiredCommitment();
    error ReleaseConfigDigestMismatch(bytes32 expected, bytes32 computed);

    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------

    /// @notice Permanent provenance anchor emitted when constructor validation
    ///         and HELLBOX_ABI_V1 digest verification succeed.
    event PublicationConfigured(
        bytes32 indexed releaseConfigDigest,
        string publicationKey,
        uint256 indexed chainId,
        address indexed factory,
        uint256 publicationVersion,
        bytes32 publicationManifestDigest,
        bytes32 packageDigest
    );

    // ---------------------------------------------------------------------
    // Construction / freeze boundary
    // ---------------------------------------------------------------------

    constructor(
        ReleaseConfig memory config,
        CommitmentSet memory commitments,
        bytes32 expectedReleaseConfigDigest
    ) ERC721(config.collectionName, config.collectionSymbol) {
        _validateReleaseConfig(config, commitments);

        uint256 chainId_ = block.chainid;
        address factory_ = msg.sender;

        bytes32 commitmentsDigest_ = keccak256(abi.encode(commitments));
        bytes32 computedReleaseConfigDigest = _computeReleaseConfigDigest(
            chainId_,
            factory_,
            config,
            commitments
        );

        if (computedReleaseConfigDigest != expectedReleaseConfigDigest) {
            revert ReleaseConfigDigestMismatch(
                expectedReleaseConfigDigest,
                computedReleaseConfigDigest
            );
        }

        publicationKey = config.publicationKey;

        releaseChainId = chainId_;
        factory = factory_;

        maxSupply = config.maxSupply;
        primaryLifetimeCap = config.primaryLifetimeCap;
        maxPerTransaction = config.maxPerTransaction;

        immediateCreatorRecipient = config.immediateCreatorRecipient;
        immediateCreatorCount = config.immediateCreatorCount;

        tailRecipient = config.tailRecipient;
        tailReserveCount = config.tailReserveCount;

        royaltyReceiver = config.royaltyReceiver;
        royaltyBps = config.royaltyBps;

        publisherAuthority = config.publisherAuthority;

        readerEnabled = config.readerEnabled;
        sealEnabled = config.sealEnabled;
        archiveCompatible = config.archiveCompatible;
        dynamicMetadataEnabled = config.dynamicMetadataEnabled;
        erc6551Compatible = config.erc6551Compatible;
        rewardsCompatible = config.rewardsCompatible;
        hellforgeCompatible = config.hellforgeCompatible;
        contextualTraitsEnabled = config.contextualTraitsEnabled;

        publicationManifestDigest = commitments.publicationManifestDigest;
        packageDigest = commitments.packageDigest;
        commitmentsDigest = commitmentsDigest_;
        releaseConfigDigest = computedReleaseConfigDigest;

        configFrozen = true;
        frozenAtBlock = block.number;
        frozenAtTimestamp = block.timestamp;

        if (config.royaltyBps > 0) {
            _setDefaultRoyalty(config.royaltyReceiver, config.royaltyBps);
        }

        emit PublicationConfigured(
            computedReleaseConfigDigest,
            config.publicationKey,
            chainId_,
            factory_,
            PUBLICATION_VERSION,
            commitments.publicationManifestDigest,
            commitments.packageDigest
        );
    }

    // ---------------------------------------------------------------------
    // Public commitment helpers
    // ---------------------------------------------------------------------

    /// @notice Computes the aggregate digest of the exact HELLBOX_ABI_V1
    ///         CommitmentSet field order.
    function computeCommitmentsDigest(
        CommitmentSet calldata commitments
    ) external pure returns (bytes32) {
        return keccak256(abi.encode(commitments));
    }

    /// @notice Computes a HELLBOX_ABI_V1 release digest for cross-language
    ///         verification and golden test vectors.
    /// @dev Constructor deployment uses actual block.chainid and actual msg.sender.
    function computeReleaseConfigDigest(
        uint256 chainId,
        address factoryAddress,
        ReleaseConfig calldata config,
        CommitmentSet calldata commitments
    ) external pure returns (bytes32) {
        return
            _computeReleaseConfigDigest(
                chainId,
                factoryAddress,
                config,
                commitments
            );
    }

    // ---------------------------------------------------------------------
    // Internal commitment encoding
    // ---------------------------------------------------------------------

    function _computeReleaseConfigDigest(
        uint256 chainId,
        address factoryAddress,
        ReleaseConfig memory config,
        CommitmentSet memory commitments
    ) internal pure returns (bytes32) {
        return
            keccak256(
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
    // Constructor validation
    // ---------------------------------------------------------------------

    function _validateReleaseConfig(
        ReleaseConfig memory config,
        CommitmentSet memory commitments
    ) internal pure {
        _validatePublicationKey(config.publicationKey);
        _validateCollectionName(config.collectionName);
        _validateCollectionSymbol(config.collectionSymbol);

        if (config.maxSupply == 0) {
            revert InvalidMaxSupply();
        }

        if (
            config.primaryLifetimeCap == 0 ||
            config.primaryLifetimeCap > config.maxSupply
        ) {
            revert InvalidPrimaryLifetimeCap(
                config.primaryLifetimeCap,
                config.maxSupply
            );
        }

        if (
            config.maxPerTransaction == 0 ||
            config.maxPerTransaction > config.primaryLifetimeCap
        ) {
            revert InvalidMaxPerTransaction(
                config.maxPerTransaction,
                config.primaryLifetimeCap
            );
        }

        if (
            config.immediateCreatorCount > config.maxSupply ||
            config.tailReserveCount > config.maxSupply ||
            config.immediateCreatorCount + config.tailReserveCount >
            config.maxSupply
        ) {
            revert InvalidCreatorAllocation(
                config.immediateCreatorCount,
                config.tailReserveCount,
                config.maxSupply
            );
        }

        if (
            (config.immediateCreatorCount > 0 &&
                config.immediateCreatorRecipient == address(0)) ||
            (config.immediateCreatorCount == 0 &&
                config.immediateCreatorRecipient != address(0))
        ) {
            revert InvalidImmediateCreatorRecipient();
        }

        if (
            (config.tailReserveCount > 0 &&
                config.tailRecipient == address(0)) ||
            (config.tailReserveCount == 0 &&
                config.tailRecipient != address(0))
        ) {
            revert InvalidTailRecipient();
        }

        if (
            config.royaltyBps > 10_000 ||
            (config.royaltyBps > 0 &&
                config.royaltyReceiver == address(0)) ||
            (config.royaltyBps == 0 &&
                config.royaltyReceiver != address(0))
        ) {
            revert InvalidRoyaltyConfiguration(
                config.royaltyReceiver,
                config.royaltyBps
            );
        }

        if (config.publisherAuthority == address(0)) {
            revert InvalidPublisherAuthority();
        }

        if (
            (config.archiveCompatible && !config.sealEnabled) ||
            (config.rewardsCompatible && !config.archiveCompatible) ||
            (config.contextualTraitsEnabled &&
                !config.dynamicMetadataEnabled)
        ) {
            revert InvalidCapabilityConfiguration();
        }

        if (
            commitments.publicationManifestDigest == bytes32(0) ||
            commitments.packageDigest == bytes32(0)
        ) {
            revert MissingRequiredCommitment();
        }
    }

    function _validatePublicationKey(string memory value) internal pure {
        bytes memory key = bytes(value);
        uint256 length = key.length;

        if (length == 0 || length > 64) {
            revert InvalidPublicationKey();
        }

        bool previousWasHyphen = false;

        for (uint256 i = 0; i < length; ++i) {
            uint8 character = uint8(key[i]);
            bool isAlphaNumeric = _isLowerAlphaNumeric(character);
            bool isHyphen = character == 0x2d;

            if (!isAlphaNumeric && !isHyphen) {
                revert InvalidPublicationKey();
            }

            if (isHyphen) {
                if (
                    i == 0 ||
                    i == length - 1 ||
                    previousWasHyphen
                ) {
                    revert InvalidPublicationKey();
                }
                previousWasHyphen = true;
            } else {
                previousWasHyphen = false;
            }
        }
    }

    function _validateCollectionName(string memory value) internal pure {
        uint256 length = bytes(value).length;

        if (length == 0 || length > 128) {
            revert InvalidCollectionNameLength(length);
        }
    }

    function _validateCollectionSymbol(string memory value) internal pure {
        bytes memory symbolBytes = bytes(value);
        uint256 length = symbolBytes.length;

        if (length == 0 || length > 16) {
            revert InvalidCollectionSymbol();
        }

        for (uint256 i = 0; i < length; ++i) {
            uint8 character = uint8(symbolBytes[i]);

            // Visible ASCII only: 0x21 (!) through 0x7e (~).
            if (character < 0x21 || character > 0x7e) {
                revert InvalidCollectionSymbol();
            }
        }
    }

    function _isLowerAlphaNumeric(
        uint8 character
    ) internal pure returns (bool) {
        return
            (character >= 0x61 && character <= 0x7a) ||
            (character >= 0x30 && character <= 0x39);
    }
}
