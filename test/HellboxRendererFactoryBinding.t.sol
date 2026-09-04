// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxPublicationFactory} from "../contracts/HellboxPublicationFactory.sol";
import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxArtDataStore} from "../contracts/HellboxArtDataStore.sol";
import {HellboxNativeRendererV1} from "../contracts/HellboxNativeRendererV1.sol";

interface IRendererBindingVm {
    function expectPartialRevert(bytes4 revertData) external;
    function prank(address msgSender) external;
}

contract FactoryRendererBindingHarness is HellboxPublicationFactory {
    constructor(address initialOwner)
        HellboxPublicationFactory(
            initialOwner, bytes32(uint256(1)), bytes32(uint256(2)), address(1), bytes32(uint256(3))
        )
    {}

    function registerPublicationForTest(address publication) external {
        isPublication[publication] = true;
    }
}

/// @dev Only the frozen commitment digest matters to renderer binding.
contract FactoryRendererPublicationMock {
    bytes32 public immutable commitmentsDigest;

    constructor(bytes32 commitmentsDigest_) {
        commitmentsDigest = commitmentsDigest_;
    }
}

/// @notice Permanent tests for the exact renderer the release already froze.
/// @dev The point of these is narrow and important: the factory owner must not
///      be able to bind a renderer that serves different art, a different
///      canvas or a different renderer version than the published release
///      committed to before any copy existed.
contract HellboxRendererFactoryBindingTest {
    IRendererBindingVm internal constant VM =
        IRendererBindingVm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address internal constant OUTSIDER = 0xB00000000000000000000000000000000000000B;

    uint256 internal constant CANVAS_WIDTH = 1988;
    uint256 internal constant CANVAS_HEIGHT = 3056;

    bytes4 internal constant OWNABLE_UNAUTHORIZED = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));

    struct Fixture {
        FactoryRendererBindingHarness factory;
        address publication;
        address store;
        HellboxPublication.CommitmentSet commitments;
        HellboxPublicationFactory.RendererPreimages preimages;
        bytes constructorArguments;
    }

    function testFactoryDeploysAndPermanentlyBindsTheFrozenRenderer() public {
        Fixture memory fixture = _fixture();

        address renderer = fixture.factory.deployRenderer(
            fixture.publication,
            fixture.commitments,
            fixture.preimages,
            type(HellboxNativeRendererV1).creationCode,
            fixture.constructorArguments
        );

        require(renderer.code.length != 0, "renderer code");
        require(fixture.factory.rendererByPublication(fixture.publication) == renderer, "publication lookup");
        require(fixture.factory.publicationByRenderer(renderer) == fixture.publication, "renderer lookup");

        HellboxNativeRendererV1 bound = HellboxNativeRendererV1(renderer);
        require(bound.rendererId() == keccak256("HELLBOX_NATIVE_RENDERER"), "renderer id");
        require(bound.interfaceVersion() == 1, "interface version");
        require(bound.artDataStore() == fixture.store, "bound art store");
        require(bound.canvasWidth() == CANVAS_WIDTH && bound.canvasHeight() == CANVAS_HEIGHT, "bound canvas");

        // The binding is append-only: there is no rebind, replace or upgrade.
        VM.expectPartialRevert(HellboxPublicationFactory.RendererAlreadyRegistered.selector);
        fixture.factory.deployRenderer(
            fixture.publication,
            fixture.commitments,
            fixture.preimages,
            type(HellboxNativeRendererV1).creationCode,
            fixture.constructorArguments
        );
    }

    function testFactoryRejectsRendererCodeThatIsNotTheFrozenApproval() public {
        Fixture memory fixture = _fixture();

        VM.expectPartialRevert(HellboxPublicationFactory.UnapprovedRendererCreationCode.selector);
        fixture.factory.deployRenderer(
            fixture.publication,
            fixture.commitments,
            fixture.preimages,
            type(FactoryRendererPublicationMock).creationCode,
            fixture.constructorArguments
        );

        require(fixture.factory.rendererByPublication(fixture.publication) == address(0), "nothing recorded");
    }

    function testFactoryRejectsARendererServingDifferentArt() public {
        Fixture memory fixture = _fixture();

        // Same approved renderer code, but pointed at a substituted plate.
        bytes memory otherPlate = bytes('<rect width="1988" height="3056" fill="#ffffff"/>');
        address otherStore = address(new HellboxArtDataStore(otherPlate, keccak256(otherPlate)));

        VM.expectPartialRevert(HellboxPublicationFactory.RendererArtDataStoreMismatch.selector);
        fixture.factory.deployRenderer(
            fixture.publication,
            fixture.commitments,
            fixture.preimages,
            type(HellboxNativeRendererV1).creationCode,
            abi.encode(otherStore, otherStore.codehash, CANVAS_WIDTH, CANVAS_HEIGHT)
        );

        require(fixture.factory.rendererByPublication(fixture.publication) == address(0), "nothing recorded");
    }

    function testFactoryRejectsACanvasTheReleaseDidNotFreeze() public {
        Fixture memory fixture = _fixture();

        VM.expectPartialRevert(HellboxPublicationFactory.RendererCanvasMismatch.selector);
        fixture.factory.deployRenderer(
            fixture.publication,
            fixture.commitments,
            fixture.preimages,
            type(HellboxNativeRendererV1).creationCode,
            abi.encode(fixture.store, fixture.store.codehash, uint256(1000), uint256(1500))
        );

        require(fixture.factory.rendererByPublication(fixture.publication) == address(0), "nothing recorded");
    }

    function testFactoryRejectsCommitmentsThatAreNotThePublicationsOwn() public {
        Fixture memory fixture = _fixture();

        HellboxPublication.CommitmentSet memory tampered = fixture.commitments;
        tampered.packageDigest = keccak256("a different package");

        VM.expectPartialRevert(HellboxPublicationFactory.RendererCommitmentsDigestMismatch.selector);
        fixture.factory.deployRenderer(
            fixture.publication,
            tampered,
            fixture.preimages,
            type(HellboxNativeRendererV1).creationCode,
            fixture.constructorArguments
        );
    }

    function testFactoryRejectsPreimagesOutsideTheFrozenRendererRules() public {
        Fixture memory fixture = _fixture();

        HellboxPublicationFactory.RendererPreimages memory tampered = fixture.preimages;
        tampered.rendererVersion = 2;

        VM.expectPartialRevert(HellboxPublicationFactory.RendererRulesDigestMismatch.selector);
        fixture.factory.deployRenderer(
            fixture.publication,
            fixture.commitments,
            tampered,
            type(HellboxNativeRendererV1).creationCode,
            fixture.constructorArguments
        );
    }

    function testUnofficialPublicationCannotReceiveARenderer() public {
        Fixture memory fixture = _fixture();

        address unofficial = address(new FactoryRendererPublicationMock(keccak256("not official")));

        VM.expectPartialRevert(HellboxPublicationFactory.UnofficialRendererPublication.selector);
        fixture.factory.deployRenderer(
            unofficial,
            fixture.commitments,
            fixture.preimages,
            type(HellboxNativeRendererV1).creationCode,
            fixture.constructorArguments
        );
    }

    function testOnlyFactoryOwnerCanBindARenderer() public {
        Fixture memory fixture = _fixture();

        VM.prank(OUTSIDER);
        VM.expectPartialRevert(OWNABLE_UNAUTHORIZED);
        fixture.factory.deployRenderer(
            fixture.publication,
            fixture.commitments,
            fixture.preimages,
            type(HellboxNativeRendererV1).creationCode,
            fixture.constructorArguments
        );

        require(fixture.factory.rendererByPublication(fixture.publication) == address(0), "nothing recorded");
    }

    function _fixture() internal returns (Fixture memory fixture) {
        fixture.factory = new FactoryRendererBindingHarness(address(this));

        bytes memory plate = bytes('<rect width="1988" height="3056" fill="#0b0b0f"/>');
        fixture.store = address(new HellboxArtDataStore(plate, keccak256(plate)));

        fixture.preimages = HellboxPublicationFactory.RendererPreimages({
            rendererId: keccak256("HELLBOX_NATIVE_RENDERER"),
            rendererVersion: 1,
            interfaceVersion: 1,
            rendererCreationCodeHash: keccak256(type(HellboxNativeRendererV1).creationCode),
            artDataStore: fixture.store,
            artDataStoreCodeHash: fixture.store.codehash,
            canvasWidth: CANVAS_WIDTH,
            canvasHeight: CANVAS_HEIGHT
        });

        fixture.commitments.publicationManifestDigest = keccak256("renderer-binding-manifest");
        fixture.commitments.packageDigest = keccak256("renderer-binding-package");
        fixture.commitments.rendererRulesDigest = fixture.factory.rendererRulesDigest(fixture.preimages);

        fixture.publication =
            address(new FactoryRendererPublicationMock(keccak256(abi.encode(fixture.commitments))));
        fixture.factory.registerPublicationForTest(fixture.publication);

        fixture.constructorArguments =
            abi.encode(fixture.store, fixture.store.codehash, CANVAS_WIDTH, CANVAS_HEIGHT);
    }
}
