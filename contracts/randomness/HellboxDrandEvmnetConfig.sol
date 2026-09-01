// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

/// @title HellboxDrandEvmnetConfig
/// @notice Canonical Testnet-only identity and schedule rules for the drand
///         `evmnet` source selected by the Gate 4 randomness architecture.
/// @dev This library performs no signature verification and stores no state.
///      It freezes only source identity, round-message encoding, and round/time
///      conversion so later verifier and publication code cannot reinterpret
///      those values. Mainnet use remains prohibited until the complete
///      verifier/security-review barrier passes.
library HellboxDrandEvmnetConfig {
    // ---------------------------------------------------------------------
    // Hellbox / provider identity
    // ---------------------------------------------------------------------

    bytes32 internal constant VERIFIER_ID =
        keccak256("HELLBOX_DRAND_EVMNET_VERIFIER_V1");

    bytes32 internal constant PROVIDER_CONFIG_DOMAIN =
        keccak256("HELLBOX_DRAND_EVMNET_PROVIDER_CONFIG_V1");

    bytes32 internal constant SOURCE_CHAIN_HASH =
        0x04f1e9062b8a81f848fded9c12306733282b2727ecced50032187751166ec8c3;

    bytes32 internal constant SCHEME_ID =
        keccak256("bls-bn254-unchained-on-g1");

    bytes32 internal constant HASH_TO_CURVE_DOMAIN_HASH = keccak256(
        "BLS_SIG_BN254G1_XMD:KECCAK-256_SVDW_RO_NUL_"
    );

    bytes32 internal constant ROUND_MESSAGE_ENCODING_ID = keccak256(
        "KECCAK256_ABI_ENCODE_PACKED_UINT64_AS_32_BYTE_MESSAGE_V1"
    );

    uint64 internal constant GENESIS_TIME = 1_727_521_075;
    uint32 internal constant PERIOD_SECONDS = 3;

    // Canonical 128-byte drand public key, in transport order.
    bytes32 internal constant PUBLIC_KEY_CHUNK_0 =
        0x07e1d1d335df83fa98462005690372c643340060d205306a9aa8106b6bd0b382;
    bytes32 internal constant PUBLIC_KEY_CHUNK_1 =
        0x0557ec32c2ad488e4d4f6008f89a346f18492092ccc0d594610de2732c8b808f;
    bytes32 internal constant PUBLIC_KEY_CHUNK_2 =
        0x0095685ae3a85ba243747b1b2f426049010f6b73a0cf1d389351d5aaaa1047f6;
    bytes32 internal constant PUBLIC_KEY_CHUNK_3 =
        0x297d3a4f9749b33eb2d904c9d9ebf17224150ddd7abd7567a9bec6c74480ee0b;

    bytes32 internal constant PUBLIC_KEY_SHA256 =
        0x4f49eb77a5fc5907f5ffc6042459ae6e0b5c8148b2a0f35e352bec23328b3249;

    // ---------------------------------------------------------------------
    // Errors
    // ---------------------------------------------------------------------

    error InvalidRound(uint64 round);
    error RoundTimestampOverflow(uint64 round);

    // ---------------------------------------------------------------------
    // Canonical identity
    // ---------------------------------------------------------------------

    function verifierId() internal pure returns (bytes32) {
        return VERIFIER_ID;
    }

    function sourceChainHash() internal pure returns (bytes32) {
        return SOURCE_CHAIN_HASH;
    }

    function schemeId() internal pure returns (bytes32) {
        return SCHEME_ID;
    }

    function genesisTime() internal pure returns (uint64) {
        return GENESIS_TIME;
    }

    function periodSeconds() internal pure returns (uint32) {
        return PERIOD_SECONDS;
    }

    function publicKeySha256() internal pure returns (bytes32) {
        return PUBLIC_KEY_SHA256;
    }

    function hashToCurveDomainHash() internal pure returns (bytes32) {
        return HASH_TO_CURVE_DOMAIN_HASH;
    }

    function roundMessageEncodingId() internal pure returns (bytes32) {
        return ROUND_MESSAGE_ENCODING_ID;
    }

    function publicKeyChunks()
        internal
        pure
        returns (bytes32[4] memory chunks)
    {
        chunks[0] = PUBLIC_KEY_CHUNK_0;
        chunks[1] = PUBLIC_KEY_CHUNK_1;
        chunks[2] = PUBLIC_KEY_CHUNK_2;
        chunks[3] = PUBLIC_KEY_CHUNK_3;
    }

    /// @notice Digest of every source-level value frozen by this library.
    /// @dev The approved verifier runtime code hash and publication policy
    ///      parameters are bound separately at their proper authority layers.
    function providerConfigDigest() internal pure returns (bytes32) {
        // Every encoded item below is static and occupies one 32-byte ABI word.
        // Concatenating these smaller group encodings is therefore byte-for-byte
        // identical to one abi.encode call over all thirteen values, while
        // avoiding an old-codegen stack-depth failure when this internal
        // library function is inlined into a caller.
        bytes memory identity = abi.encode(
            PROVIDER_CONFIG_DOMAIN,
            VERIFIER_ID,
            SOURCE_CHAIN_HASH,
            SCHEME_ID,
            GENESIS_TIME,
            PERIOD_SECONDS
        );

        bytes memory publicKey = abi.encode(
            PUBLIC_KEY_CHUNK_0,
            PUBLIC_KEY_CHUNK_1,
            PUBLIC_KEY_CHUNK_2,
            PUBLIC_KEY_CHUNK_3,
            PUBLIC_KEY_SHA256
        );

        bytes memory protocol = abi.encode(
            HASH_TO_CURVE_DOMAIN_HASH,
            ROUND_MESSAGE_ENCODING_ID
        );

        return keccak256(bytes.concat(identity, publicKey, protocol));
    }

    /// @notice Exact message digest signed for an `evmnet` round.
    /// @dev The BLS hash-to-curve layer receives `abi.encodePacked(result)`.
    function roundMessageDigest(
        uint64 round
    ) internal pure returns (bytes32) {
        if (round == 0) {
            revert InvalidRound(round);
        }

        return keccak256(abi.encodePacked(round));
    }

    // ---------------------------------------------------------------------
    // Canonical round schedule
    // ---------------------------------------------------------------------

    /// @notice First round whose canonical timestamp is at or after `timestamp`.
    function firstRoundAtOrAfter(
        uint64 timestamp
    ) internal pure returns (uint64 round) {
        if (timestamp <= GENESIS_TIME) {
            return 1;
        }

        uint256 delta = uint256(timestamp) - GENESIS_TIME;
        uint256 roundedPeriods =
            (delta + PERIOD_SECONDS - 1) / PERIOD_SECONDS;

        round = uint64(roundedPeriods + 1);
    }

    /// @notice Canonical Unix timestamp for `round`.
    function roundTimestamp(
        uint64 round
    ) internal pure returns (uint64 timestamp) {
        if (round == 0) {
            revert InvalidRound(round);
        }

        uint256 computed = uint256(GENESIS_TIME) +
            (uint256(round) - 1) * PERIOD_SECONDS;

        if (computed > type(uint64).max) {
            revert RoundTimestampOverflow(round);
        }

        timestamp = uint64(computed);
    }
}
