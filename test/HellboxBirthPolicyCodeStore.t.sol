// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";

/// @notice Gate 4 V1 proof that the immutable code store is inert on ordinary
///         calls and carries the exact HellboxBirthPolicy creation bytecode
///         after its one-byte STOP prefix.
contract HellboxBirthPolicyCodeStoreTest {
    function testRuntimeLayoutMatchesExactBirthPolicyCreationCode() public {
        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();

        bytes memory expected = type(HellboxBirthPolicy).creationCode;
        bytes memory actual = address(store).code;

        require(
            actual.length == expected.length + 1,
            "runtime length"
        );
        require(actual[0] == bytes1(0x00), "missing STOP prefix");

        for (uint256 i; i < expected.length; ++i) {
            require(
                actual[i + 1] == expected[i],
                "creation byte mismatch"
            );
        }
    }

    function testRuntimeHashCommitsStopPrefixedCreationCode() public {
        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();

        bytes memory expectedRuntime = bytes.concat(
            hex"00",
            type(HellboxBirthPolicy).creationCode
        );

        require(
            address(store).codehash == keccak256(expectedRuntime),
            "runtime codehash"
        );
    }

    function testCopiedPayloadHashMatchesBirthPolicyCreationCodeHash() public {
        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();

        uint256 payloadLength = address(store).code.length - 1;
        bytes memory payload = new bytes(payloadLength);

        assembly ("memory-safe") {
            extcodecopy(
                store,
                add(payload, 0x20),
                1,
                payloadLength
            )
        }

        require(
            keccak256(payload) ==
                keccak256(type(HellboxBirthPolicy).creationCode),
            "payload creation-code hash"
        );
    }

    function testOrdinaryCallIsInert() public {
        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();

        (bool ok, bytes memory returnData) =
            address(store).call(hex"deadbeef");

        require(ok, "ordinary call reverted");
        require(returnData.length == 0, "ordinary call returned data");
    }
}
