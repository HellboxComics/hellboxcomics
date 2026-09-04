// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Base64} from "openzeppelin-contracts/contracts/utils/Base64.sol";

import {HellboxArtDataStore} from "../contracts/HellboxArtDataStore.sol";
import {HellboxNativeRendererV1} from "../contracts/HellboxNativeRendererV1.sol";

interface IHellboxRendererVm {
    function expectRevert(bytes calldata revertData) external;
    function etch(address target, bytes calldata newRuntimeBytecode) external;
}

/// @dev Minimal publication surface the renderer actually reads.
contract RendererMockPublication {
    address public birthPolicy;
    string public name;

    constructor(address policy, string memory collectionName) {
        birthPolicy = policy;
        name = collectionName;
    }
}

/// @dev Minimal birth-identity surface the renderer actually reads.
contract RendererMockBirthPolicy {
    mapping(uint256 tokenId => bool assigned) public birthIdentityAssigned;
    mapping(uint256 tokenId => bytes32 markCode) public birthMark;
    mapping(uint256 tokenId => bytes32 defectCode) public birthDefect;

    function assign(uint256 tokenId, bytes32 markCode, bytes32 defectCode) external {
        birthIdentityAssigned[tokenId] = true;
        birthMark[tokenId] = markCode;
        birthDefect[tokenId] = defectCode;
    }
}

/// @dev A publication whose every call fails. Metadata must survive it.
contract RendererHostilePublication {
    fallback() external {
        revert("publication unavailable");
    }
}

/// @notice Permanent tests for the Gate 4 immutable metadata renderer.
/// @dev No new test dependency. These prove the frozen render path and the
///      self-contained data URI, not the later art compiler.
contract HellboxNativeRendererTest {
    IHellboxRendererVm internal constant VM =
        IHellboxRendererVm(address(uint160(uint256(keccak256("hevm cheat code")))));

    uint256 internal constant CANVAS_WIDTH = 1000;
    uint256 internal constant CANVAS_HEIGHT = 1500;

    string internal constant DESCRIPTION =
        "Hellbox native artifact. The canonical cover is stored on-chain in immutable data and composed by a frozen renderer.";

    // A storage/render fixture, not authored comic content.
    bytes internal constant PLATE =
        bytes('<rect width="1000" height="1500" fill="#0b0b0f"/><text x="40" y="80" fill="#f05a22">PROVING PLATE</text>');

    function testRendererIdentityIsFrozen() public {
        HellboxNativeRendererV1 renderer = _deployRenderer();
        require(renderer.rendererId() == keccak256("HELLBOX_NATIVE_RENDERER"), "renderer id");
        require(renderer.rendererVersion() == 1, "renderer version");
        require(renderer.interfaceVersion() == 1, "interface version");
        require(renderer.canvasWidth() == CANVAS_WIDTH && renderer.canvasHeight() == CANVAS_HEIGHT, "canvas");
    }

    function testConstructorRejectsZeroStore() public {
        VM.expectRevert(abi.encodeWithSelector(HellboxNativeRendererV1.ArtDataStoreRequired.selector));
        new HellboxNativeRendererV1(address(0), keccak256(PLATE), CANVAS_WIDTH, CANVAS_HEIGHT);
    }

    function testConstructorRejectsEmptyCanvas() public {
        address store = _deployStore(PLATE);
        bytes32 codeHash = store.codehash;

        VM.expectRevert(abi.encodeWithSelector(HellboxNativeRendererV1.InvalidCanvas.selector, uint256(0), CANVAS_HEIGHT));
        new HellboxNativeRendererV1(store, codeHash, 0, CANVAS_HEIGHT);

        VM.expectRevert(abi.encodeWithSelector(HellboxNativeRendererV1.InvalidCanvas.selector, CANVAS_WIDTH, uint256(0)));
        new HellboxNativeRendererV1(store, codeHash, CANVAS_WIDTH, 0);
    }

    function testConstructorRejectsWrongStoreCodeHash() public {
        address store = _deployStore(PLATE);
        bytes32 actual = store.codehash;
        bytes32 wrong = bytes32(uint256(actual) ^ uint256(1));

        VM.expectRevert(
            abi.encodeWithSelector(HellboxNativeRendererV1.ArtDataStoreCodeHashMismatch.selector, wrong, actual)
        );
        new HellboxNativeRendererV1(store, wrong, CANVAS_WIDTH, CANVAS_HEIGHT);
    }

    function testPlateRoundTripsExactlyOutOfImmutableStorage() public {
        HellboxNativeRendererV1 renderer = _deployRenderer();
        bytes memory recovered = renderer.plateBytes();
        require(keccak256(recovered) == keccak256(PLATE), "plate bytes");
    }

    function testCanonicalSvgWrapsPlateInFrozenCanvas() public {
        HellboxNativeRendererV1 renderer = _deployRenderer();
        require(keccak256(bytes(renderer.previewSvg())) == keccak256(_expectedSvg()), "composed svg");
    }

    function testTokenUriIsExactAndSelfContained() public {
        (HellboxNativeRendererV1 renderer, address publication,) = _deployFullFixture("HELLBOX SCIVIVE");
        _assignTraits(publication, 7, keccak256("GOLD"), keccak256("NONE"));

        string memory expected = _expectedTokenUri(
            "HELLBOX SCIVIVE",
            7,
            ',{"trait_type":"Press Mark","value":"GOLD"},{"trait_type":"Press Defect","value":"NONE"}'
        );

        require(
            keccak256(bytes(renderer.tokenURI(publication, 7))) == keccak256(bytes(expected)), "exact token uri"
        );
    }

    function testEveryStandardMarkAndDefectLabelRenders() public {
        (HellboxNativeRendererV1 renderer, address publication,) = _deployFullFixture("HELLBOX");

        bytes32[4] memory markCodes = [
            keccak256("HELLBOUND"),
            keccak256("PRESS_PROOF"),
            keccak256("GOLD"),
            keccak256("STANDARD")
        ];
        // Assigned individually: an array literal of differently sized string
        // literals has no single deducible element type.
        string[4] memory markLabels;
        markLabels[0] = "HELLBOUND";
        markLabels[1] = "PRESS PROOF";
        markLabels[2] = "GOLD";
        markLabels[3] = "STANDARD";

        bytes32[5] memory defectCodes = [
            keccak256("REDACTED"),
            keccak256("CORRUPTED_PLATE"),
            keccak256("BLED_OUT"),
            keccak256("OFF_REGISTER"),
            keccak256("NONE")
        ];
        string[5] memory defectLabels;
        defectLabels[0] = "REDACTED";
        defectLabels[1] = "CORRUPTED PLATE";
        defectLabels[2] = "BLED OUT";
        defectLabels[3] = "OFF REGISTER";
        defectLabels[4] = "NONE";

        uint256 tokenId;
        for (uint256 m; m < markCodes.length; ++m) {
            for (uint256 d; d < defectCodes.length; ++d) {
                tokenId += 1;
                _assignTraits(publication, tokenId, markCodes[m], defectCodes[d]);

                string memory expected = _expectedTokenUri(
                    "HELLBOX",
                    tokenId,
                    string.concat(
                        ',{"trait_type":"Press Mark","value":"',
                        markLabels[m],
                        '"},{"trait_type":"Press Defect","value":"',
                        defectLabels[d],
                        '"}'
                    )
                );

                require(
                    keccak256(bytes(renderer.tokenURI(publication, tokenId))) == keccak256(bytes(expected)),
                    "label pair"
                );
            }
        }
    }

    function testUnknownBirthCodeRendersUnrecordedInsteadOfReverting() public {
        (HellboxNativeRendererV1 renderer, address publication,) = _deployFullFixture("HELLBOX");
        _assignTraits(publication, 9, keccak256("SOMETHING_LATER"), keccak256("ALSO_LATER"));

        string memory expected = _expectedTokenUri(
            "HELLBOX",
            9,
            ',{"trait_type":"Press Mark","value":"UNRECORDED"},{"trait_type":"Press Defect","value":"UNRECORDED"}'
        );

        require(keccak256(bytes(renderer.tokenURI(publication, 9))) == keccak256(bytes(expected)), "unknown code");
    }

    function testTraitDisabledReleasePublishesNoTraitAttributes() public {
        (HellboxNativeRendererV1 renderer, address publication,) = _deployFullFixture("HELLBOX SCIVIVE");
        // Trait-disabled publications assign zeroed codes.
        _assignTraits(publication, 3, bytes32(0), bytes32(0));

        string memory expected = _expectedTokenUri("HELLBOX SCIVIVE", 3, "");
        require(keccak256(bytes(renderer.tokenURI(publication, 3))) == keccak256(bytes(expected)), "trait disabled");
    }

    function testUnassignedCopyPublishesNoTraitAttributes() public {
        (HellboxNativeRendererV1 renderer, address publication,) = _deployFullFixture("HELLBOX");

        string memory expected = _expectedTokenUri("HELLBOX", 42, "");
        require(keccak256(bytes(renderer.tokenURI(publication, 42))) == keccak256(bytes(expected)), "unassigned");
    }

    function testHostilePublicationCannotBrickTheBaseCover() public {
        HellboxNativeRendererV1 renderer = _deployRenderer();
        address hostile = address(new RendererHostilePublication());

        // Falls back to the deterministic collection name and drops traits,
        // but the canonical cover still renders.
        string memory expected = _expectedTokenUri("HELLBOX", 1, "");
        require(keccak256(bytes(renderer.tokenURI(hostile, 1))) == keccak256(bytes(expected)), "hostile publication");
    }

    function testCollectionNameQuotesAndBackslashesAreEscaped() public {
        (HellboxNativeRendererV1 renderer, address publication,) = _deployFullFixture('HELL"BOX\\PRESS');

        string memory expected = _expectedTokenUri('HELL\\"BOX\\\\PRESS', 5, "");
        require(keccak256(bytes(renderer.tokenURI(publication, 5))) == keccak256(bytes(expected)), "escaped name");
    }

    function testControlCharacterInNameIsEscapedAsUnicode() public {
        (HellboxNativeRendererV1 renderer, address publication,) = _deployFullFixture(string(abi.encodePacked("HB", bytes1(0x0a))));

        string memory expected = _expectedTokenUri("HB\\u000a", 5, "");
        require(keccak256(bytes(renderer.tokenURI(publication, 5))) == keccak256(bytes(expected)), "escaped control");
    }

    function testReplacedArtDataRevertsInsteadOfServingWrongArt() public {
        HellboxNativeRendererV1 renderer = _deployRenderer();
        address store = renderer.artDataStore();
        bytes32 expectedCodeHash = renderer.artDataStoreCodeHash();

        // Simulate the store's runtime being replaced. The renderer must
        // refuse to serve substituted canonical art.
        bytes memory replaced = hex"00ffffff";
        VM.etch(store, replaced);

        VM.expectRevert(
            abi.encodeWithSelector(
                HellboxNativeRendererV1.ArtDataStoreCodeHashMismatch.selector, expectedCodeHash, keccak256(replaced)
            )
        );
        renderer.plateBytes();
    }

    function _deployStore(bytes memory data) internal returns (address) {
        return address(new HellboxArtDataStore(data, keccak256(data)));
    }

    function _deployRenderer() internal returns (HellboxNativeRendererV1) {
        address store = _deployStore(PLATE);
        return new HellboxNativeRendererV1(store, store.codehash, CANVAS_WIDTH, CANVAS_HEIGHT);
    }

    function _deployFullFixture(string memory collectionName)
        internal
        returns (HellboxNativeRendererV1 renderer, address publication, address policy)
    {
        renderer = _deployRenderer();
        policy = address(new RendererMockBirthPolicy());
        publication = address(new RendererMockPublication(policy, collectionName));
    }

    function _assignTraits(address publication, uint256 tokenId, bytes32 markCode, bytes32 defectCode) internal {
        address policy = RendererMockPublication(publication).birthPolicy();
        RendererMockBirthPolicy(policy).assign(tokenId, markCode, defectCode);
    }

    function _expectedSvg() internal pure returns (bytes memory) {
        return abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1500" viewBox="0 0 1000 1500"',
            ' shape-rendering="geometricPrecision"><g id="plate">',
            PLATE,
            "</g></svg>"
        );
    }

    function _expectedTokenUri(string memory escapedName, uint256 tokenId, string memory traitAttributes)
        internal
        pure
        returns (string memory)
    {
        bytes memory json = abi.encodePacked(
            '{"name":"',
            escapedName,
            " #",
            _toString(tokenId),
            '","description":"',
            DESCRIPTION,
            '","image":"data:image/svg+xml;base64,',
            Base64.encode(_expectedSvg()),
            '","attributes":[{"trait_type":"Copy","display_type":"number","value":',
            _toString(tokenId),
            "}",
            traitAttributes,
            "]}"
        );

        return string.concat("data:application/json;base64,", Base64.encode(json));
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

        uint256 digits;
        for (uint256 probe = value; probe != 0; probe /= 10) {
            ++digits;
        }

        bytes memory buffer = new bytes(digits);
        for (uint256 i = digits; i != 0; --i) {
            buffer[i - 1] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }

        return string(buffer);
    }
}
