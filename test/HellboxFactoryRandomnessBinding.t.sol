// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxPublicationFactory} from "../contracts/HellboxPublicationFactory.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";
import {IHellboxRandomnessVerifier} from "../contracts/interfaces/IHellboxRandomnessVerifier.sol";
import {HellboxDrandEvmnetVerifier} from "../contracts/randomness/HellboxDrandEvmnetVerifier.sol";

contract HellboxFactoryRandomnessBindingTest {
    uint256 internal constant EIP170_RUNTIME_LIMIT = 24_576;
    uint256 internal constant EIP3860_INITCODE_LIMIT = 49_152;

    bytes32 internal constant EXPECTED_VERIFIER_ID =
        keccak256("HELLBOX_DRAND_EVMNET_VERIFIER_V1");

    bytes32 internal constant EXPECTED_PROVIDER_CONFIG_DIGEST =
        0x0d191efbb2f605bf73b6f3c4819b21bc8c7a64393c6dcfd43b6b2f6b5be401e3;

    function testFactoryDeploysAndFreezesExpectedVerifier() public {
        HellboxPublicationFactory factory = _newFactory();
        address verifierAddress = factory.randomnessVerifier();

        require(verifierAddress != address(0), "zero verifier");
        require(verifierAddress.code.length > 0, "missing verifier code");

        IHellboxRandomnessVerifier verifier =
            IHellboxRandomnessVerifier(verifierAddress);

        require(
            factory.RANDOMNESS_VERIFIER_ID() == EXPECTED_VERIFIER_ID,
            "factory verifier id"
        );
        require(
            verifier.verifierId() == EXPECTED_VERIFIER_ID,
            "reported verifier id"
        );
        require(
            factory.RANDOMNESS_PROVIDER_CONFIG_DIGEST() ==
                EXPECTED_PROVIDER_CONFIG_DIGEST,
            "factory provider digest"
        );
        require(
            verifier.providerConfigDigest() ==
                EXPECTED_PROVIDER_CONFIG_DIGEST,
            "reported provider digest"
        );
        require(
            verifierAddress.codehash ==
                factory.randomnessVerifierRuntimeCodeHash(),
            "stored verifier code hash"
        );
        require(
            verifierAddress.codehash ==
                keccak256(type(HellboxDrandEvmnetVerifier).runtimeCode),
            "reviewed verifier runtime"
        );
    }

    function testSeparateFactoryGenerationsUseDistinctEquivalentVerifiers()
        public
    {
        HellboxPublicationFactory first = _newFactory();
        HellboxPublicationFactory second = _newFactory();

        address firstVerifier = first.randomnessVerifier();
        address secondVerifier = second.randomnessVerifier();

        require(firstVerifier != secondVerifier, "same verifier address");
        require(
            firstVerifier.codehash == secondVerifier.codehash,
            "different verifier runtime"
        );
        require(
            first.randomnessVerifierRuntimeCodeHash() ==
                second.randomnessVerifierRuntimeCodeHash(),
            "different frozen code hash"
        );
    }

    function testFactoryAndVerifierRemainInsideDeploymentLimits() public {
        HellboxPublicationFactory factory = _newFactory();
        address verifierAddress = factory.randomnessVerifier();

        require(
            address(factory).code.length < EIP170_RUNTIME_LIMIT,
            "factory runtime exceeds EIP-170"
        );
        require(
            verifierAddress.code.length < EIP170_RUNTIME_LIMIT,
            "verifier runtime exceeds EIP-170"
        );

        uint256 factoryInitCodeLength =
            type(HellboxPublicationFactory).creationCode.length +
            abi.encode(
                address(this),
                bytes32(uint256(1)),
                address(1),
                bytes32(uint256(1))
            ).length;

        require(
            factoryInitCodeLength < EIP3860_INITCODE_LIMIT,
            "factory initcode exceeds EIP-3860"
        );
    }

    function testExistingFactoryConstructorSignatureIsPreserved() public {
        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();

        HellboxPublicationFactory factory =
            new HellboxPublicationFactory(
                address(this),
                keccak256(type(HellboxPublication).creationCode),
                address(store),
                keccak256(type(HellboxBirthPolicy).creationCode)
            );

        require(address(factory) != address(0), "factory");
        require(factory.owner() == address(this), "owner");
    }

    function _newFactory()
        internal
        returns (HellboxPublicationFactory factory)
    {
        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();

        factory = new HellboxPublicationFactory(
            address(this),
            keccak256(type(HellboxPublication).creationCode),
            address(store),
            keccak256(type(HellboxBirthPolicy).creationCode)
        );
    }
}
