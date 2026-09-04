// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

/// @title IHellboxMetadataRenderer
/// @notice Gate 4 metadata/render interface between a publication kernel and
///         its frozen, non-upgradeable renderer sidecar.
/// @dev The publication holds no rendering logic and no art bytes. It forwards
///      `tokenURI` to exactly one permanently bound renderer generation and
///      returns whatever that renderer produces.
///
///      Implementations must be immutable: no owner, no setter, no proxy or
///      upgrade path, and no reachable SELFDESTRUCT. A renderer is never
///      upgraded in place; a new approved renderer generation is deployed and
///      bound to future publications instead.
///
///      `rendererId` names a stable renderer family. `rendererVersion` names
///      an exact implementation inside that family. `interfaceVersion` names
///      this call shape, so a publication can verify compatibility before
///      binding without knowing anything about the renderer's internals.
interface IHellboxMetadataRenderer {
    /// @notice Stable renderer family identifier.
    function rendererId() external view returns (bytes32);

    /// @notice Exact implementation version inside the renderer family.
    function rendererVersion() external view returns (uint256);

    /// @notice Metadata/render call-shape generation implemented here.
    function interfaceVersion() external view returns (uint256);

    /// @notice Complete, self-contained metadata for one copy.
    /// @dev Must return a fully self-contained data URI. No external URL,
    ///      gateway, CID or host may be required to reconstruct the canonical
    ///      cover. Reverting is reserved for genuinely missing or replaced
    ///      canonical art data; an unavailable optional overlay source must
    ///      degrade to the deterministic base cover instead of reverting.
    /// @param publication Publication whose copy is being rendered.
    /// @param tokenId Copy number being rendered.
    function tokenURI(address publication, uint256 tokenId) external view returns (string memory);
}
