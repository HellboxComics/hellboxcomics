// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Base64} from "openzeppelin-contracts/contracts/utils/Base64.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

import {IHellboxMetadataRenderer} from "./interfaces/IHellboxMetadataRenderer.sol";

/// @title HellboxNativeRendererV1
/// @notice Gate 4 immutable metadata renderer for native Hellbox issues.
/// @dev This renderer proves the frozen render path end to end: immutable art
///      bytes are read out of an inert `HellboxArtDataStore` by `EXTCODECOPY`,
///      wrapped in a frozen canvas envelope, and returned inside a completely
///      self-contained JSON data URI. Nothing it returns depends on a URL,
///      gateway, CID, host, script, external font or remote stylesheet.
///
///      It has no owner, no setter, no proxy path, no upgrade path and no
///      reachable SELFDESTRUCT. Every configured value is a constructor
///      immutable, so the deployed runtime code hash commits to this
///      renderer's exact output behavior, including its canvas and its art
///      data store binding.
///
///      Deliberately NOT in scope here (Gate 6): deterministic MARK/DEFECT
///      layer compositing, layer families, shared render assets, history and
///      context layers, and the Archive slab layer. Birth identity is proven
///      here as frozen metadata attributes over an immutable base plate. The
///      painter order and layer grammar arrive with the art compiler and get a
///      new renderer generation, never an in-place upgrade of this one.
///
///      Every read of publication or companion state is defensive. A
///      publication that cannot answer degrades to the deterministic base
///      cover instead of bricking a collector's metadata. Only genuinely
///      missing or substituted canonical art reverts, because serving the
///      wrong art silently is worse than serving none.
///
///      Pairing note: the canonical art store bound here belongs to one
///      publication's release. The publication passes its own address when it
///      forwards `tokenURI`, and the factory binds exactly one renderer to
///      exactly one publication. A third party calling this renderer with an
///      unrelated publication address reads this store's plate beside that
///      publication's traits; it is a meaningless read, never a write, and it
///      cannot alter any artifact.
contract HellboxNativeRendererV1 is IHellboxMetadataRenderer {
    using Strings for uint256;

    bytes32 private constant RENDERER_ID = keccak256("HELLBOX_NATIVE_RENDERER");
    uint256 private constant RENDERER_VERSION = 1;
    uint256 private constant INTERFACE_VERSION = 1;

    // Standard native PRESS MARK vocabulary.
    bytes32 private constant MARK_HELLBOUND = keccak256("HELLBOUND");
    bytes32 private constant MARK_PRESS_PROOF = keccak256("PRESS_PROOF");
    bytes32 private constant MARK_GOLD = keccak256("GOLD");
    bytes32 private constant MARK_STANDARD = keccak256("STANDARD");

    // Standard native PRESS DEFECT vocabulary.
    bytes32 private constant DEFECT_REDACTED = keccak256("REDACTED");
    bytes32 private constant DEFECT_CORRUPTED_PLATE = keccak256("CORRUPTED_PLATE");
    bytes32 private constant DEFECT_BLED_OUT = keccak256("BLED_OUT");
    bytes32 private constant DEFECT_OFF_REGISTER = keccak256("OFF_REGISTER");
    bytes32 private constant DEFECT_NONE = keccak256("NONE");

    /// @dev Deterministic label for a code outside this renderer generation's
    ///      frozen vocabulary. Never reverts: an unknown birth code must not
    ///      be able to remove a collector's cover from every marketplace.
    string private constant UNRECORDED_LABEL = "UNRECORDED";

    /// @dev Used only when a publication cannot report its own collection
    ///      name. Keeps metadata alive rather than bricking the token.
    string private constant FALLBACK_COLLECTION_NAME = "HELLBOX";

    string private constant DESCRIPTION =
        "Hellbox native artifact. The canonical cover is stored on-chain in immutable data and composed by a frozen renderer.";

    /// @notice Inert art-data store holding the canonical plate bytes.
    address public immutable artDataStore;

    /// @notice Exact runtime code hash the art-data store must keep forever.
    bytes32 public immutable artDataStoreCodeHash;

    /// @notice Frozen canvas dimensions for the composed SVG envelope.
    uint256 public immutable canvasWidth;
    uint256 public immutable canvasHeight;

    error ArtDataStoreRequired();
    error InvalidCanvas(uint256 width, uint256 height);
    error ArtDataStoreHasNoPayload();
    error ArtDataStoreCodeHashMismatch(bytes32 expectedCodeHash, bytes32 actualCodeHash);

    /// @param store Deployed `HellboxArtDataStore` holding the plate fragment.
    /// @param expectedCodeHash Exact expected runtime code hash of that store.
    /// @param width Frozen canvas width.
    /// @param height Frozen canvas height.
    constructor(address store, bytes32 expectedCodeHash, uint256 width, uint256 height) {
        if (store == address(0)) {
            revert ArtDataStoreRequired();
        }
        if (width == 0 || height == 0) {
            revert InvalidCanvas(width, height);
        }

        bytes32 actualCodeHash = store.codehash;
        if (actualCodeHash != expectedCodeHash) {
            revert ArtDataStoreCodeHashMismatch(expectedCodeHash, actualCodeHash);
        }

        uint256 size;
        assembly ("memory-safe") {
            size := extcodesize(store)
        }
        // One byte is the inert STOP prefix; a payload byte must follow it.
        if (size < 2) {
            revert ArtDataStoreHasNoPayload();
        }

        artDataStore = store;
        artDataStoreCodeHash = expectedCodeHash;
        canvasWidth = width;
        canvasHeight = height;
    }

    /// @inheritdoc IHellboxMetadataRenderer
    function rendererId() external pure override returns (bytes32) {
        return RENDERER_ID;
    }

    /// @inheritdoc IHellboxMetadataRenderer
    function rendererVersion() external pure override returns (uint256) {
        return RENDERER_VERSION;
    }

    /// @inheritdoc IHellboxMetadataRenderer
    function interfaceVersion() external pure override returns (uint256) {
        return INTERFACE_VERSION;
    }

    /// @inheritdoc IHellboxMetadataRenderer
    function tokenURI(address publication, uint256 tokenId) external view override returns (string memory) {
        // Canonical art is mandatory: a missing or replaced plate is a real
        // integrity failure and must not be papered over with a placeholder.
        bytes memory plate = _readPlate();

        // Birth identity is read defensively. A publication or companion that
        // cannot answer degrades to the base cover instead of bricking it.
        (bool traitsKnown, bytes32 markCode, bytes32 defectCode) = _readBirthTraits(publication, tokenId);

        bytes memory json = abi.encodePacked(
            '{"name":"',
            _escapeJson(_collectionName(publication)),
            " #",
            tokenId.toString(),
            '","description":"',
            DESCRIPTION,
            '","image":"data:image/svg+xml;base64,',
            Base64.encode(_composeSvg(plate)),
            '","attributes":[',
            _attributes(tokenId, traitsKnown, markCode, defectCode),
            "]}"
        );

        return string.concat("data:application/json;base64,", Base64.encode(json));
    }

    /// @notice Canonical plate bytes currently held by the bound store.
    function plateBytes() external view returns (bytes memory) {
        return _readPlate();
    }

    /// @notice Composed canonical SVG for a plate, without metadata framing.
    function previewSvg() external view returns (string memory) {
        return string(_composeSvg(_readPlate()));
    }

    function _readPlate() internal view returns (bytes memory plate) {
        address store = artDataStore;

        bytes32 actualCodeHash = store.codehash;
        if (actualCodeHash != artDataStoreCodeHash) {
            revert ArtDataStoreCodeHashMismatch(artDataStoreCodeHash, actualCodeHash);
        }

        uint256 size;
        assembly ("memory-safe") {
            size := extcodesize(store)
        }
        if (size < 2) {
            revert ArtDataStoreHasNoPayload();
        }

        // Skip the inert STOP prefix; the payload is the remaining bytes.
        plate = new bytes(size - 1);
        assembly ("memory-safe") {
            extcodecopy(store, add(plate, 0x20), 1, mload(plate))
        }
    }

    function _composeSvg(bytes memory plate) internal view returns (bytes memory) {
        string memory width = canvasWidth.toString();
        string memory height = canvasHeight.toString();

        return abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" width="',
            width,
            '" height="',
            height,
            '" viewBox="0 0 ',
            width,
            " ",
            height,
            '" shape-rendering="geometricPrecision"><g id="plate">',
            plate,
            "</g></svg>"
        );
    }

    function _attributes(uint256 tokenId, bool traitsKnown, bytes32 markCode, bytes32 defectCode)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory copyAttribute =
            abi.encodePacked('{"trait_type":"Copy","display_type":"number","value":', tokenId.toString(), "}");

        // A trait-disabled release, or a copy whose birth identity is not yet
        // assigned, publishes no MARK/DEFECT attributes at all rather than
        // publishing an invented or empty trait value.
        if (!traitsKnown || (markCode == bytes32(0) && defectCode == bytes32(0))) {
            return copyAttribute;
        }

        return abi.encodePacked(
            copyAttribute,
            ',{"trait_type":"Press Mark","value":"',
            _markLabel(markCode),
            '"},{"trait_type":"Press Defect","value":"',
            _defectLabel(defectCode),
            '"}'
        );
    }

    function _markLabel(bytes32 code) internal pure returns (string memory) {
        if (code == MARK_STANDARD) return "STANDARD";
        if (code == MARK_GOLD) return "GOLD";
        if (code == MARK_PRESS_PROOF) return "PRESS PROOF";
        if (code == MARK_HELLBOUND) return "HELLBOUND";
        return UNRECORDED_LABEL;
    }

    function _defectLabel(bytes32 code) internal pure returns (string memory) {
        if (code == DEFECT_NONE) return "NONE";
        if (code == DEFECT_OFF_REGISTER) return "OFF REGISTER";
        if (code == DEFECT_BLED_OUT) return "BLED OUT";
        if (code == DEFECT_CORRUPTED_PLATE) return "CORRUPTED PLATE";
        if (code == DEFECT_REDACTED) return "REDACTED";
        return UNRECORDED_LABEL;
    }

    /// @dev The bound publication is an official factory-deployed contract
    ///      whose `name()` comes from the pinned ERC-721 implementation, so a
    ///      well-formed ABI string is expected. An unreachable, reverting or
    ///      too-short answer falls back rather than reverting.
    function _collectionName(address publication) internal view returns (string memory) {
        (bool ok, bytes memory result) = publication.staticcall(abi.encodeWithSignature("name()"));
        if (!ok || result.length < 64) {
            return FALLBACK_COLLECTION_NAME;
        }

        string memory collectionName = abi.decode(result, (string));
        if (bytes(collectionName).length == 0) {
            return FALLBACK_COLLECTION_NAME;
        }

        return collectionName;
    }

    /// @dev Every word is decoded as raw `bytes32` and narrowed here, so a
    ///      malformed or dirty return value can never revert this view and
    ///      erase a collector's cover.
    function _readBirthTraits(address publication, uint256 tokenId)
        internal
        view
        returns (bool traitsKnown, bytes32 markCode, bytes32 defectCode)
    {
        (bool ok, bytes memory result) = publication.staticcall(abi.encodeWithSignature("birthPolicy()"));
        if (!ok || result.length != 32) {
            return (false, bytes32(0), bytes32(0));
        }

        address policy = address(uint160(uint256(abi.decode(result, (bytes32)))));
        if (policy == address(0)) {
            return (false, bytes32(0), bytes32(0));
        }

        uint256 policySize;
        assembly ("memory-safe") {
            policySize := extcodesize(policy)
        }
        if (policySize == 0) {
            return (false, bytes32(0), bytes32(0));
        }

        (ok, result) = policy.staticcall(abi.encodeWithSignature("birthIdentityAssigned(uint256)", tokenId));
        if (!ok || result.length != 32 || abi.decode(result, (bytes32)) == bytes32(0)) {
            return (false, bytes32(0), bytes32(0));
        }

        (ok, result) = policy.staticcall(abi.encodeWithSignature("birthMark(uint256)", tokenId));
        if (!ok || result.length != 32) {
            return (false, bytes32(0), bytes32(0));
        }
        markCode = abi.decode(result, (bytes32));

        (ok, result) = policy.staticcall(abi.encodeWithSignature("birthDefect(uint256)", tokenId));
        if (!ok || result.length != 32) {
            return (false, bytes32(0), bytes32(0));
        }
        defectCode = abi.decode(result, (bytes32));

        traitsKnown = true;
    }

    /// @dev Collection names are only length-validated at the publication, so
    ///      any byte may appear here. Quotes, backslashes and control bytes
    ///      are escaped so a frozen release name can never produce malformed
    ///      metadata JSON.
    function _escapeJson(string memory value) internal pure returns (string memory) {
        bytes memory raw = bytes(value);
        uint256 length = raw.length;
        bytes memory escaped = new bytes(length * 6);
        uint256 cursor;

        for (uint256 i; i < length; ++i) {
            uint8 character = uint8(raw[i]);

            if (character == 0x22) {
                escaped[cursor] = bytes1(uint8(0x5c));
                escaped[cursor + 1] = bytes1(uint8(0x22));
                cursor += 2;
            } else if (character == 0x5c) {
                escaped[cursor] = bytes1(uint8(0x5c));
                escaped[cursor + 1] = bytes1(uint8(0x5c));
                cursor += 2;
            } else if (character < 0x20) {
                escaped[cursor] = bytes1(uint8(0x5c));
                escaped[cursor + 1] = bytes1(uint8(0x75));
                escaped[cursor + 2] = bytes1(uint8(0x30));
                escaped[cursor + 3] = bytes1(uint8(0x30));
                escaped[cursor + 4] = _hexDigit(character >> 4);
                escaped[cursor + 5] = _hexDigit(character & 0x0f);
                cursor += 6;
            } else {
                escaped[cursor] = bytes1(character);
                cursor += 1;
            }
        }

        // Shrink to the written length, which is always inside the allocation.
        assembly ("memory-safe") {
            mstore(escaped, cursor)
        }

        return string(escaped);
    }

    function _hexDigit(uint8 nibble) internal pure returns (bytes1) {
        return bytes1(nibble < 10 ? uint8(48) + nibble : uint8(87) + nibble);
    }
}
