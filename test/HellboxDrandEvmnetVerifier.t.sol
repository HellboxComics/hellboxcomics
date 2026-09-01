// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxDrandEvmnetVerifier} from
    "../contracts/randomness/HellboxDrandEvmnetVerifier.sol";

contract HellboxDrandEvmnetVerifierProbeTest {
    uint64 private constant ROUND = 20_239_652;
    uint64 private constant WRONG_ROUND = 20_239_653;

    bytes32 private constant EXPECTED_RANDOMNESS =
        0x8ccbb7b50d16a27eef4906baa2256b7fa95a3fe0db33edd988b91f070f05e2b2;
    bytes32 private constant EXPECTED_PROVIDER_DIGEST =
        0x0d191efbb2f605bf73b6f3c4819b21bc8c7a64393c6dcfd43b6b2f6b5be401e3;
    bytes4 private constant VERIFY_ROUND_SELECTOR =
        bytes4(keccak256("verifyRound(uint64,bytes)"));

    HellboxDrandEvmnetVerifier private verifier;

    event VerificationGas(uint256 gasUsed);

    function setUp() public {
        verifier = new HellboxDrandEvmnetVerifier();
    }

    function _proof() private pure returns (bytes memory) {
        return
            hex"1e8d8d4790679ad4ebf7ee4b62b022195578a21837e91ee305333b742c19e291174b857abe086f82a9fed4c04d5faafcbeab1de2d9919a7158c67fb8c89e8335";
    }

    function _selector(bytes memory revertData)
        private
        pure
        returns (bytes4 result)
    {
        require(revertData.length >= 4, "short revert data");
        assembly {
            result := mload(add(revertData, 0x20))
        }
    }

    function _expectRevert(bytes memory callData, bytes4 expected) private {
        (bool success, bytes memory revertData) =
            address(verifier).staticcall(callData);

        require(!success, "unexpected success");
        require(_selector(revertData) == expected, "wrong selector");
    }

    function testFrozenIdentityAndProviderDigest() public view {
        require(
            verifier.verifierId() ==
                keccak256("HELLBOX_DRAND_EVMNET_VERIFIER_V1"),
            "verifier id"
        );
        require(
            verifier.providerConfigDigest() == EXPECTED_PROVIDER_DIGEST,
            "provider digest"
        );
    }

    function testCanonicalRoundSchedule() public view {
        require(verifier.firstRoundAtOrAfter(1_727_521_075) == 1, "genesis");
        require(verifier.firstRoundAtOrAfter(1_727_521_076) == 2, "+1");
        require(verifier.firstRoundAtOrAfter(1_727_521_078) == 2, "+3");
        require(verifier.firstRoundAtOrAfter(1_727_521_079) == 3, "+4");
        require(verifier.roundTimestamp(ROUND) == 1_788_240_028, "timestamp");
    }

    function testExactObservedRoundVerifiesUnder300kGas() public {
        uint256 gasBefore = gasleft();
        bytes32 randomness = verifier.verifyRound(ROUND, _proof());
        uint256 gasUsed = gasBefore - gasleft();

        emit VerificationGas(gasUsed);
        require(randomness == EXPECTED_RANDOMNESS, "randomness");
        require(gasUsed < 300_000, "verification gas");
    }

    function testRepeatedVerificationIsStateless() public view {
        bytes memory proof = _proof();
        bytes32 first = verifier.verifyRound(ROUND, proof);
        bytes32 second = verifier.verifyRound(ROUND, proof);

        require(first == EXPECTED_RANDOMNESS, "first");
        require(second == EXPECTED_RANDOMNESS, "second");
    }

    function testWrongRoundValidPointIsRejected() public {
        _expectRevert(
            abi.encodeWithSelector(
                VERIFY_ROUND_SELECTOR,
                WRONG_ROUND,
                _proof()
            ),
            bytes4(keccak256("InvalidSignature()"))
        );
    }

    function testMalformedPointIsRejected() public {
        _expectRevert(
            abi.encodeWithSelector(
                VERIFY_ROUND_SELECTOR,
                ROUND,
                new bytes(64)
            ),
            bytes4(keccak256("InvalidSignaturePoint()"))
        );
    }

    function testShortProofIsRejected() public {
        _expectRevert(
            abi.encodeWithSelector(
                VERIFY_ROUND_SELECTOR,
                ROUND,
                new bytes(63)
            ),
            bytes4(keccak256("InvalidProofLength(uint256)"))
        );
    }

    function testRoundZeroIsRejected() public {
        _expectRevert(
            abi.encodeWithSelector(
                VERIFY_ROUND_SELECTOR,
                uint64(0),
                _proof()
            ),
            bytes4(keccak256("InvalidRound(uint64)"))
        );
    }
}
