// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

/// @title IHellboxRandomnessVerifier
/// @notice Immutable external verification boundary for future-round randomness.
/// @dev Implementations MUST be non-upgradeable for a factory generation,
///      MUST revert for malformed or invalid proofs, and MUST NOT substitute
///      timestamp, caller input, publisher choice, or any other fallback entropy.
///      Publications consume only the returned verified randomness word.
interface IHellboxRandomnessVerifier {
    /// @notice Stable identifier for the verifier protocol/implementation family.
    function verifierId() external view returns (bytes32);

    /// @notice Digest committing the exact provider identity and verification
    ///         configuration used by this verifier generation.
    /// @dev For drand this is expected to bind, at minimum, the network chain
    ///      hash, scheme, public key, genesis timestamp, period, domain and
    ///      verifier version. A publication/factory must compare this value
    ///      against its approved generation configuration before relying on it.
    function providerConfigDigest() external view returns (bytes32);

    /// @notice Returns the first provider round whose canonical timestamp is
    ///         greater than or equal to `unixTimestamp`.
    /// @dev Used to choose a future round at request time and a deterministic
    ///      post-deadline round for native timed closure.
    function firstRoundAtOrAfter(
        uint64 unixTimestamp
    ) external view returns (uint64 round);

    /// @notice Returns the canonical Unix timestamp for `round`.
    function roundTimestamp(
        uint64 round
    ) external view returns (uint64 unixTimestamp);

    /// @notice Cryptographically verifies `proof` for exactly `round` and
    ///         returns the provider randomness committed by that proof.
    /// @dev Invalid length, malformed points, wrong-round signatures and all
    ///      other invalid proofs MUST revert. The function MUST have no callback
    ///      into the publication and is intended to be invoked through STATICCALL.
    function verifyRound(
        uint64 round,
        bytes calldata proof
    ) external view returns (bytes32 randomness);
}
