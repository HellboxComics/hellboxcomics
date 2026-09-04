// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxArtDataStore} from "../contracts/HellboxArtDataStore.sol";

interface IHellboxArtDataStoreVm {
    function deal(address account, uint256 newBalance) external;
    function expectRevert(bytes calldata revertData) external;
}

/// @notice Permanent tests for the immutable art-byte store, not the renderer.
/// @dev No new test dependency. Constructor failures must return the exact
///      custom error, including arguments; a generic creation failure is not a pass.
contract HellboxArtDataStoreTest {
    IHellboxArtDataStoreVm internal constant VM =
        IHellboxArtDataStoreVm(address(uint160(uint256(keccak256("hevm cheat code")))));

    uint256 internal constant MAX_DATA_BYTES = 24_575;

    function testMinimumOneBytePayload() public {
        bytes memory data = hex"a5";
        address store = _deploy(data);
        _assertStore(store, data);
        require(keccak256(store.code) == keccak256(hex"00a5"), "minimum runtime");
    }

    function testRuntimeIsExactlyStopPlusPayload() public {
        bytes memory data = hex"000102037f80aabbccddeeff005b6000fd";
        address store = _deploy(data);
        bytes memory runtime = store.code;
        require(runtime.length == data.length + 1, "runtime suffix or truncation");
        require(runtime[0] == bytes1(0), "missing STOP");
        for (uint256 i; i < data.length; ++i) {
            require(runtime[i + 1] == data[i], "runtime byte mismatch");
        }
    }

    function testPayloadRoundTripsThroughExtcodecopy() public {
        // A storage fixture, not an authored or deployed comic.
        bytes memory data = bytes('<svg xmlns="http://www.w3.org/2000/svg"><text>G4 storage fixture</text></svg>');
        address store = _deploy(data);
        bytes memory recovered = _readPayload(store);
        require(recovered.length == data.length, "copy length");
        require(keccak256(recovered) == keccak256(data), "copy bytes");
    }

    function testRuntimeCodehashCommitsTheStopPrefix() public {
        bytes memory data = hex"010203040506";
        address store = _deploy(data);
        require(store.codehash == keccak256(bytes.concat(hex"00", data)), "full codehash");
        require(store.codehash != keccak256(data), "payload hash used as runtime hash");
    }

    function testEmptyPayloadRevertsWithExactError() public {
        bytes memory data = new bytes(0);
        _expectRejected(data, keccak256(data), abi.encodeWithSelector(HellboxArtDataStore.EmptyArtData.selector));
    }

    function testWrongPayloadHashRevertsWithExactError() public {
        bytes memory data = hex"102030405060";
        bytes32 actual = keccak256(data);
        bytes32 wrong = bytes32(uint256(actual) ^ uint256(1));
        _expectRejected(
            data, wrong, abi.encodeWithSelector(HellboxArtDataStore.ArtDataHashMismatch.selector, wrong, actual)
        );
    }

    function testPrefixedRuntimeHashIsNotAcceptedAsPayloadHash() public {
        bytes memory data = hex"11223300aabbcc";
        bytes32 actual = keccak256(data);
        bytes32 prefixed = keccak256(bytes.concat(hex"00", data));
        _expectRejected(
            data, prefixed, abi.encodeWithSelector(HellboxArtDataStore.ArtDataHashMismatch.selector, prefixed, actual)
        );
    }

    function testFirstOversizedPayloadRevertsWithExactError() public {
        bytes memory data = new bytes(MAX_DATA_BYTES + 1);
        _expectRejected(
            data,
            keccak256(data),
            abi.encodeWithSelector(HellboxArtDataStore.ArtDataTooLarge.selector, data.length, MAX_DATA_BYTES)
        );
    }

    function testMaximumPayloadRoundTrips() public {
        bytes memory data = _pattern(MAX_DATA_BYTES, keccak256("maximum art chunk"));
        address store = _deploy(data);
        _assertStore(store, data);
        require(store.code.length == 24_576, "maximum runtime");
    }

    function testAbiWordBoundaryPayloadsRoundTrip() public {
        uint256[6] memory lengths = [uint256(31), 32, 33, 63, 64, 65];
        for (uint256 i; i < lengths.length; ++i) {
            bytes memory data = _pattern(lengths[i], keccak256(abi.encode(i)));
            _assertStore(_deploy(data), data);
        }
    }

    function testOrdinaryCallsReturnNoDataAndLeaveBytesUnchanged() public {
        bytes memory data = hex"aabbccdd00010203";
        address store = _deploy(data);
        _assertInertCall(store, new bytes(0));
        _assertInertCall(store, hex"deadbeef");
        _assertStore(store, data);
    }

    function testOpcodeLookingPayloadIsNeverExecuted() public {
        // Without the leading STOP, this begins PUSH1 0, PUSH1 0, REVERT.
        bytes memory data = hex"60006000fd5b33ff";
        address store = _deploy(data);
        _assertInertCall(store, hex"01020304");
        _assertStore(store, data);
    }

    function testSetterAndOwnerSelectorsCannotRewritePayload() public {
        bytes memory data = hex"0123456789abcdef";
        address store = _deploy(data);
        bytes memory replacement = hex"ffff";
        _assertInertCall(store, abi.encodeWithSignature("setData(bytes)", replacement));
        _assertInertCall(store, abi.encodeWithSignature("transferOwnership(address)", address(this)));
        _assertInertCall(store, abi.encodeWithSignature("upgradeTo(address)", address(this)));
        _assertInertCall(store, abi.encodeWithSignature("owner()"));
        _assertStore(store, data);
    }

    function testValueCallHoldsValueWithoutChangingCode() public {
        // Records the documented footgun: sending value is accepted, not rescued.
        bytes memory data = hex"feff";
        address store = _deploy(data);
        VM.deal(address(this), 1);
        (bool ok, bytes memory returned) = store.call{value: 1}(hex"deadbeef");
        require(ok && returned.length == 0, "value call");
        require(store.balance == 1, "value balance");
        _assertInertCall(store, abi.encodeWithSignature("withdraw()"));
        require(store.balance == 1, "unexpected withdrawal");
        _assertStore(store, data);
    }

    function testFuzzPayloadRoundTrip(bytes memory data) public {
        // Exercise through the first rejected size, without allowing huge fuzz
        // calldata to fail CREATE's initcode limit before our constructor runs.
        if (data.length > MAX_DATA_BYTES + 1) {
            assembly ("memory-safe") {
                mstore(data, 24576)
            }
        }
        if (data.length == 0) {
            _expectRejected(data, keccak256(data), abi.encodeWithSelector(HellboxArtDataStore.EmptyArtData.selector));
        } else if (data.length > MAX_DATA_BYTES) {
            _expectRejected(
                data,
                keccak256(data),
                abi.encodeWithSelector(HellboxArtDataStore.ArtDataTooLarge.selector, data.length, MAX_DATA_BYTES)
            );
        } else {
            _assertStore(_deploy(data), data);
        }
    }

    function testFuzzWrongHashAlwaysRejected(bytes32 seed, uint16 sizeSeed) public {
        // Bound allocations without discarding fuzz cases. The separate boundary
        // tests cover the maximum accepted and first rejected payload lengths.
        bytes memory data = _pattern(1 + uint256(sizeSeed) % 1_024, seed);
        bytes32 actual = keccak256(data);
        bytes32 wrong = bytes32(uint256(actual) ^ uint256(1));
        _expectRejected(
            data, wrong, abi.encodeWithSelector(HellboxArtDataStore.ArtDataHashMismatch.selector, wrong, actual)
        );
    }

    function _deploy(bytes memory data) internal returns (address) {
        return address(new HellboxArtDataStore(data, keccak256(data)));
    }

    function _assertStore(address store, bytes memory data) internal view {
        bytes memory runtime = store.code;
        require(runtime.length == data.length + 1, "exact runtime length");
        require(runtime[0] == bytes1(0), "STOP prefix");
        bytes32 expectedRuntimeHash = keccak256(bytes.concat(hex"00", data));
        require(keccak256(runtime) == expectedRuntimeHash, "exact runtime bytes");
        require(store.codehash == expectedRuntimeHash, "runtime codehash");
        bytes memory recovered = _readPayload(store);
        require(recovered.length == data.length, "recovered length");
        require(keccak256(recovered) == keccak256(data), "recovered payload hash");
    }

    function _readPayload(address store) internal view returns (bytes memory data) {
        uint256 length = store.code.length;
        require(length > 1, "store has no payload");
        data = new bytes(length - 1);
        assembly ("memory-safe") {
            extcodecopy(store, add(data, 0x20), 1, mload(data))
        }
    }

    function _assertInertCall(address store, bytes memory input) internal {
        bytes32 beforeHash = store.codehash;
        (bool ok, bytes memory returned) = store.call(input);
        require(ok, "inert call reverted");
        require(returned.length == 0, "inert call returned bytes");
        require(store.codehash == beforeHash, "inert call changed code");
    }

    function _expectRejected(bytes memory data, bytes32 claimedHash, bytes memory expectedError) internal {
        // vm.expectRevert on the cheatcode address matches the exact revert
        // data (selector + arguments) of the very next external call/creation.
        // This replaces a manual try/catch, which does not reliably surface
        // the constructor's raw revert data through this contract's own
        // require() on every forge/solc combination.
        VM.expectRevert(expectedError);
        new HellboxArtDataStore(data, claimedHash);
    }

    function _pattern(uint256 length, bytes32 seed) internal pure returns (bytes memory data) {
        require(length != 0, "empty test pattern");
        data = new bytes(length);
        // Solidity allocates the byte array with word-rounded capacity.
        // Writing the final padded word remains within that allocation.
        for (uint256 i; i < length; i += 32) {
            assembly ("memory-safe") {
                mstore(add(add(data, 0x20), i), seed)
            }
        }
        data[0] = bytes1(0xa5);
        data[length - 1] = bytes1(0x5a);
    }
}
