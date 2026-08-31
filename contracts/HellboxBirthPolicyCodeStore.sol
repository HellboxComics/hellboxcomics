// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxBirthPolicy} from "./HellboxBirthPolicy.sol";

/// @title HellboxBirthPolicyCodeStore
/// @notice Gate 4 V1 immutable bytecode store for the exact reviewed
///         HellboxBirthPolicy creation bytecode.
/// @dev Runtime byte zero is STOP so an ordinary call to this address is inert.
///      Bytes [1..] are exactly `type(HellboxBirthPolicy).creationCode`.
///
///      Publications can read `code.length - 1`, copy from runtime offset 1
///      with EXTCODECOPY, verify the copied bytes against the factory-approved
///      HellboxBirthPolicy creation-code hash, append canonical constructor
///      arguments, and execute CREATE themselves.
///
///      That keeps the publication as the actual CREATE caller, preserving
///      `HellboxBirthPolicy.publication = msg.sender` without a setter,
///      initializer, predicted address, proxy, delegatecall, or upgrade path.
contract HellboxBirthPolicyCodeStore {
    constructor() {
        bytes memory creationCode = type(HellboxBirthPolicy).creationCode;
        bytes memory runtime = bytes.concat(hex"00", creationCode);

        assembly ("memory-safe") {
            return(add(runtime, 0x20), mload(runtime))
        }
    }
}
