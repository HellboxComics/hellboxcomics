// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {IHellboxRandomnessVerifier} from
    "../interfaces/IHellboxRandomnessVerifier.sol";
import {HellboxDrandEvmnetConfig} from
    "./HellboxDrandEvmnetConfig.sol";

/// @title HellboxDrandEvmnetVerifier
/// @notice Stateless, non-upgradeable Gate 4 Testnet verifier for the frozen
///         drand `evmnet` BN254 configuration.
/// @dev This implementation has no owner, setter, storage, callback, fallback
///      entropy, or proof registry. It verifies one exact provider round and
///      returns SHA-256(signature), matching drand randomness derivation.
///      Mainnet use remains prohibited until the dedicated cryptography and
///      security-review barrier is complete.
///
///      The narrowed BN254 hash-to-curve and pairing construction is adapted
///      from randa-mu/bls-solidity commit
///      11af179a8287d978659aae07adb66aa60f64b8a6 (MIT), itself adapted from
///      Kevin Charm's bls-bn254 implementation.
contract HellboxDrandEvmnetVerifier is IHellboxRandomnessVerifier {
    error InvalidProofLength(uint256 actualLength);
    error InvalidSignaturePoint();
    error InvalidSignature();
    error EllipticCurveAdditionFailed();
    error ModularExponentiationFailed();
    error HashToCurveFailed(uint256 value);
    error InvalidFieldElement(uint256 value);

    uint256 private constant FIELD_MODULUS =
        0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47;

    uint256 private constant NEGATED_G2_X1 =
        0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2;
    uint256 private constant NEGATED_G2_X0 =
        0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed;
    uint256 private constant NEGATED_G2_Y1 =
        0x275dc4a288d1afb3cbb1ac09187524c7db36395df7be3b99e673b13a075a65ec;
    uint256 private constant NEGATED_G2_Y0 =
        0x1d9befcd05a5323e6da4d435f3b617cdb3af83285c2df711ef39c01571827f9d;

    uint256 private constant TWO_POW_192 =
        0x1000000000000000000000000000000000000000000000000;
    uint256 private constant MASK_192 =
        0xffffffffffffffffffffffffffffffffffffffffffffffff;

    uint256 private constant SVDW_C1 = 0x4;
    uint256 private constant SVDW_C2 =
        0x183227397098d014dc2822db40c0ac2ecbc0b548b438e5469e10460b6c3e7ea3;
    uint256 private constant SVDW_C3 =
        0x16789af3a83522eb353c98fc6b36d713d5d8d1cc5dffffffa;
    uint256 private constant SVDW_C4 =
        0x10216f7ba065e00de81ac1e7808072c9dd2b2385cd7b438469602eb24829a9bd;

    uint256 private constant LEGENDRE_EXPONENT =
        0x183227397098d014dc2822db40c0ac2ecbc0b548b438e5469e10460b6c3e7ea3;
    uint256 private constant INVERSE_EXPONENT =
        0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd45;
    uint256 private constant SQRT_EXPONENT =
        0x0c19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f52;

    string private constant HASH_TO_CURVE_DOMAIN =
        "BLS_SIG_BN254G1_XMD:KECCAK-256_SVDW_RO_NUL_";

    struct PointG1 {
        uint256 x;
        uint256 y;
    }

    struct PointG2 {
        uint256[2] x;
        uint256[2] y;
    }

    function verifierId() external pure override returns (bytes32) {
        return HellboxDrandEvmnetConfig.verifierId();
    }

    function providerConfigDigest()
        external
        pure
        override
        returns (bytes32)
    {
        return HellboxDrandEvmnetConfig.providerConfigDigest();
    }

    function firstRoundAtOrAfter(
        uint64 unixTimestamp
    ) external pure override returns (uint64 round) {
        return HellboxDrandEvmnetConfig.firstRoundAtOrAfter(unixTimestamp);
    }

    function roundTimestamp(
        uint64 round
    ) external pure override returns (uint64 unixTimestamp) {
        return HellboxDrandEvmnetConfig.roundTimestamp(round);
    }

    function verifyRound(
        uint64 round,
        bytes calldata proof
    ) external view override returns (bytes32 randomness) {
        if (proof.length != 64) {
            revert InvalidProofLength(proof.length);
        }

        PointG1 memory signature = _readSignature(proof);

        if (!_isValidPointG1(signature)) {
            revert InvalidSignaturePoint();
        }

        bytes32 roundDigest =
            HellboxDrandEvmnetConfig.roundMessageDigest(round);
        PointG1 memory message = _hashToPoint(roundDigest);

        (bool pairingSuccess, bool callSuccess) = _verifyPairing(
            signature,
            _publicKey(),
            message
        );

        if (!callSuccess || !pairingSuccess) {
            revert InvalidSignature();
        }

        bytes memory proofMemory = proof;
        randomness = sha256(proofMemory);
    }

    function _readSignature(
        bytes calldata proof
    ) private pure returns (PointG1 memory signature) {
        assembly {
            mstore(signature, calldataload(proof.offset))
            mstore(add(signature, 0x20), calldataload(add(proof.offset, 0x20)))
        }
    }

    function _publicKey() private pure returns (PointG2 memory key) {
        bytes32[4] memory chunks =
            HellboxDrandEvmnetConfig.publicKeyChunks();

        key.x[0] = uint256(chunks[1]);
        key.x[1] = uint256(chunks[0]);
        key.y[0] = uint256(chunks[3]);
        key.y[1] = uint256(chunks[2]);
    }

    function _verifyPairing(
        PointG1 memory signature,
        PointG2 memory publicKey,
        PointG1 memory message
    ) private view returns (bool pairingSuccess, bool callSuccess) {
        uint256[12] memory input = [
            signature.x,
            signature.y,
            NEGATED_G2_X1,
            NEGATED_G2_X0,
            NEGATED_G2_Y1,
            NEGATED_G2_Y0,
            message.x,
            message.y,
            publicKey.x[1],
            publicKey.x[0],
            publicKey.y[1],
            publicKey.y[0]
        ];
        uint256[1] memory output;

        assembly {
            callSuccess := staticcall(gas(), 0x08, input, 0x180, output, 0x20)
        }

        pairingSuccess = output[0] != 0;
    }

    function _isValidPointG1(
        PointG1 memory point
    ) private pure returns (bool) {
        if (point.x >= FIELD_MODULUS || point.y >= FIELD_MODULUS) {
            return false;
        }

        uint256 left = mulmod(point.y, point.y, FIELD_MODULUS);
        uint256 xSquared = mulmod(point.x, point.x, FIELD_MODULUS);
        uint256 right = addmod(
            mulmod(xSquared, point.x, FIELD_MODULUS),
            3,
            FIELD_MODULUS
        );

        return left == right;
    }

    function _hashToPoint(
        bytes32 roundDigest
    ) private view returns (PointG1 memory point) {
        uint256[2] memory fieldElements = _hashToField(roundDigest);
        PointG1 memory first = _mapToPoint(fieldElements[0]);
        PointG1 memory second = _mapToPoint(fieldElements[1]);

        point = _addG1(first, second);
    }

    function _hashToField(
        bytes32 roundDigest
    ) private pure returns (uint256[2] memory elements) {
        uint256 domainLength = bytes(HASH_TO_CURVE_DOMAIN).length;

        bytes32 b0 = keccak256(
            abi.encodePacked(
                new bytes(136),
                roundDigest,
                uint8(0),
                uint8(96),
                uint8(0),
                HASH_TO_CURVE_DOMAIN,
                uint8(domainLength)
            )
        );
        bytes32 b1 = keccak256(
            abi.encodePacked(
                b0,
                uint8(1),
                HASH_TO_CURVE_DOMAIN,
                uint8(domainLength)
            )
        );
        bytes32 b2 = keccak256(
            abi.encodePacked(
                b0 ^ b1,
                uint8(2),
                HASH_TO_CURVE_DOMAIN,
                uint8(domainLength)
            )
        );
        bytes32 b3 = keccak256(
            abi.encodePacked(
                b0 ^ b2,
                uint8(3),
                HASH_TO_CURVE_DOMAIN,
                uint8(domainLength)
            )
        );

        bytes memory expanded = abi.encodePacked(b1, b2, b3);
        uint256 high;
        uint256 low;

        assembly {
            let pointer := add(expanded, 24)
            high := and(mload(pointer), MASK_192)
            pointer := add(expanded, 48)
            low := and(mload(pointer), MASK_192)
        }

        elements[0] = addmod(
            mulmod(high, TWO_POW_192, FIELD_MODULUS),
            low,
            FIELD_MODULUS
        );

        assembly {
            let pointer := add(expanded, 72)
            high := and(mload(pointer), MASK_192)
            pointer := add(expanded, 96)
            low := and(mload(pointer), MASK_192)
        }

        elements[1] = addmod(
            mulmod(high, TWO_POW_192, FIELD_MODULUS),
            low,
            FIELD_MODULUS
        );
    }

    function _mapToPoint(
        uint256 value
    ) private view returns (PointG1 memory point) {
        if (value >= FIELD_MODULUS) {
            revert InvalidFieldElement(value);
        }

        uint256 tv1 = mulmod(
            mulmod(value, value, FIELD_MODULUS),
            SVDW_C1,
            FIELD_MODULUS
        );
        uint256 tv2 = addmod(1, tv1, FIELD_MODULUS);
        tv1 = addmod(1, FIELD_MODULUS - tv1, FIELD_MODULUS);
        uint256 tv3 = _inverse(mulmod(tv1, tv2, FIELD_MODULUS));
        uint256 tv5 = mulmod(
            mulmod(
                mulmod(value, tv1, FIELD_MODULUS),
                tv3,
                FIELD_MODULUS
            ),
            SVDW_C3,
            FIELD_MODULUS
        );
        uint256 x1 = addmod(SVDW_C2, FIELD_MODULUS - tv5, FIELD_MODULUS);
        uint256 x2 = addmod(SVDW_C2, tv5, FIELD_MODULUS);
        uint256 tv7 = mulmod(tv2, tv2, FIELD_MODULUS);
        uint256 tv8 = mulmod(tv7, tv3, FIELD_MODULUS);
        uint256 x3 = addmod(
            1,
            mulmod(SVDW_C4, mulmod(tv8, tv8, FIELD_MODULUS), FIELD_MODULUS),
            FIELD_MODULUS
        );

        uint256 curveValue;

        if (_legendre(_curveEquation(x1)) == 1) {
            point.x = x1;
            curveValue = _curveEquation(x1);
        } else if (_legendre(_curveEquation(x2)) == 1) {
            point.x = x2;
            curveValue = _curveEquation(x2);
        } else {
            point.x = x3;
            curveValue = _curveEquation(x3);
        }

        uint256 y;
        bool hasRoot;
        (y, hasRoot) = _sqrt(curveValue);

        if (!hasRoot) {
            revert HashToCurveFailed(curveValue);
        }

        point.y = y;

        if (_sign(value) != _sign(point.y)) {
            point.y = FIELD_MODULUS - point.y;
        }
    }

    function _curveEquation(uint256 x) private pure returns (uint256) {
        return addmod(
            mulmod(mulmod(x, x, FIELD_MODULUS), x, FIELD_MODULUS),
            3,
            FIELD_MODULUS
        );
    }

    function _sign(uint256 value) private pure returns (uint256) {
        return value & 1;
    }

    function _legendre(uint256 value) private view returns (int8 symbol) {
        uint256 result = _modExp(value, LEGENDRE_EXPONENT);

        if (result == 0) {
            return 0;
        }
        if (result == 1) {
            return 1;
        }
        if (result == FIELD_MODULUS - 1) {
            return -1;
        }

        revert HashToCurveFailed(value);
    }

    function _inverse(uint256 value) private view returns (uint256) {
        return _modExp(value, INVERSE_EXPONENT);
    }

    function _sqrt(
        uint256 value
    ) private view returns (uint256 root, bool hasRoot) {
        root = _modExp(value, SQRT_EXPONENT);
        hasRoot = mulmod(root, root, FIELD_MODULUS) == value;
    }

    function _modExp(
        uint256 base,
        uint256 exponent
    ) private view returns (uint256 result) {
        uint256[6] memory input = [
            uint256(32),
            uint256(32),
            uint256(32),
            base,
            exponent,
            FIELD_MODULUS
        ];
        uint256[1] memory output;
        bool success;

        assembly {
            success := staticcall(gas(), 0x05, input, 0xc0, output, 0x20)
        }

        if (!success) {
            revert ModularExponentiationFailed();
        }

        result = output[0];
    }

    function _addG1(
        PointG1 memory first,
        PointG1 memory second
    ) private view returns (PointG1 memory result) {
        uint256[4] memory input = [
            first.x,
            first.y,
            second.x,
            second.y
        ];
        uint256[2] memory output;
        bool success;

        assembly {
            success := staticcall(gas(), 0x06, input, 0x80, output, 0x40)
        }

        if (!success) {
            revert EllipticCurveAdditionFailed();
        }

        result.x = output[0];
        result.y = output[1];
    }
}
