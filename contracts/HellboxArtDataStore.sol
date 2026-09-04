// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

/// @title HellboxArtDataStore
/// @notice Gate 4 immutable storage for one nonempty canonical art-data chunk.
/// @dev The deployed runtime is exactly STOP (0x00) followed by `artData`.
///      It has no callable getters, owner, setter, proxy or reachable code
///      after STOP. Read the payload with EXTCODECOPY from offset 1, not CALL.
///
///      Consumers must verify the full runtime length/hash and payload hash
///      against the publication's frozen, ordered art-data commitments before
///      binding this address. A caller-supplied expected hash proves internal
///      consistency only; deploying a store does not establish official art
///      approval, publication provenance, format safety or a complete cover.
///
///      Do not send funds to a deployed store. Its inert STOP runtime accepts
///      ordinary calls, including value transfers, and cannot recover funds.
///      No Solidity-generated runtime or metadata suffix is returned: the
///      constructor returns the complete STOP-prefixed byte array directly.
contract HellboxArtDataStore {
    // EIP-170 permits 24,576 runtime bytes. One byte belongs to STOP.
    uint256 private constant MAX_ART_DATA_BYTES = 24_575;

    error EmptyArtData();
    error ArtDataTooLarge(uint256 actualLength, uint256 maximumLength);
    error ArtDataHashMismatch(bytes32 expectedHash, bytes32 actualHash);

    /// @param artData Exact raw bytes for one chunk, without a STOP prefix.
    /// @param expectedDataHash Expected keccak256 of those raw bytes only.
    constructor(bytes memory artData, bytes32 expectedDataHash) {
        uint256 length = artData.length;
        if (length == 0) {
            revert EmptyArtData();
        }
        if (length > MAX_ART_DATA_BYTES) {
            revert ArtDataTooLarge(length, MAX_ART_DATA_BYTES);
        }

        bytes32 actualDataHash = keccak256(artData);
        if (actualDataHash != expectedDataHash) {
            revert ArtDataHashMismatch(expectedDataHash, actualDataHash);
        }

        bytes memory runtime = bytes.concat(hex"00", artData);
        assembly ("memory-safe") {
            return(add(runtime, 0x20), mload(runtime))
        }
    }
}
