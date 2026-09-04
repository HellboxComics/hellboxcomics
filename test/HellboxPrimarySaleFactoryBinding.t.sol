// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxPublicationFactory} from "../contracts/HellboxPublicationFactory.sol";
import {HellboxPrimarySale} from "../contracts/HellboxPrimarySale.sol";

interface IFactoryBindingVm {
    function expectPartialRevert(bytes4 revertData) external;
    function expectRevert() external;
    function prank(address msgSender) external;
}

contract FactoryPrimarySaleBindingHarness is HellboxPublicationFactory {
    constructor(address initialOwner, bytes32 approvedSaleCreationCodeHash)
        HellboxPublicationFactory(
            initialOwner, bytes32(uint256(1)), approvedSaleCreationCodeHash, address(1), bytes32(uint256(2))
        )
    {}

    function registerPublicationForTest(address publication) external {
        isPublication[publication] = true;
    }
}

contract FactoryPrimarySalePublicationMock {
    address public immutable factory;
    uint256 public immutable releaseChainId;
    bytes32 public immutable releaseConfigDigest;
    bytes32 public immutable commitmentsDigest;

    uint256 public constant maxSupply = 100;
    uint256 public constant primaryLifetimeCap = 1;
    uint256 public constant maxPerTransaction = 1;
    uint256 public constant immediateCreatorCount = 0;
    uint256 public constant tailReserveCount = 0;
    uint256 public constant nativeMintDeadline = 0;
    uint256 public constant nonTailIssuanceRemaining = 100;
    bool public constant primaryIssuanceClosed = false;
    bool public constant prizeWalletIssuanceComplete = true;

    constructor(address factory_, bytes32 commitmentsDigest_) {
        factory = factory_;
        releaseChainId = block.chainid;
        releaseConfigDigest = keccak256("FACTORY_PRIMARY_SALE_BINDING_RELEASE");
        commitmentsDigest = commitmentsDigest_;
    }

    function walletLifetimePrimaryUsed(address) external pure returns (uint256) {
        return 0;
    }

    function requestCollectorPrimary(address, address) external pure returns (uint256 requestId, uint64 round) {
        return (1, 1);
    }
}

contract HellboxPrimarySaleFactoryBindingTest {
    IFactoryBindingVm internal constant VM = IFactoryBindingVm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address internal constant OUTSIDER = 0xB00000000000000000000000000000000000000B;
    bytes32 internal constant FREE_PHASE = keccak256("FACTORY_PRIMARY_SALE_FREE_PHASE");

    struct Fixture {
        FactoryPrimarySaleBindingHarness factory;
        FactoryPrimarySalePublicationMock publication;
        HellboxPrimarySale.PublicationCommitmentSet commitments;
        HellboxPrimarySale.Phase[] phases;
        bytes constructorArguments;
    }

    function testFactoryPhysicallyDeploysAndPermanentlyBindsExactSale() public {
        Fixture memory fixture = _fixture();

        address primarySale = fixture.factory
            .deployPrimarySale(
                address(fixture.publication), type(HellboxPrimarySale).creationCode, fixture.constructorArguments
            );

        require(primarySale.code.length != 0, "sale code");
        require(
            fixture.factory.primarySaleByPublication(address(fixture.publication)) == primarySale, "publication lookup"
        );
        require(fixture.factory.publicationByPrimarySale(primarySale) == address(fixture.publication), "sale lookup");

        HellboxPrimarySale sale = HellboxPrimarySale(payable(primarySale));
        require(sale.PRIMARY_SALE_ID() == fixture.factory.PRIMARY_SALE_ID(), "sale id");
        require(sale.PRIMARY_SALE_VERSION() == fixture.factory.PRIMARY_SALE_VERSION(), "sale version");
        require(sale.publication() == address(fixture.publication), "sale publication");
        require(sale.publicationFactory() == address(fixture.factory), "sale factory");
        require(sale.releaseChainId() == block.chainid, "sale chain");
        require(sale.phaseCount() == 1, "phase count");
        require(sale.nativeMintDeadline() == 0, "free timer");

        VM.expectPartialRevert(HellboxPublicationFactory.PrimarySaleAlreadyRegistered.selector);
        fixture.factory
            .deployPrimarySale(
                address(fixture.publication), type(HellboxPrimarySale).creationCode, fixture.constructorArguments
            );
    }

    function testFactoryRejectsWrongSaleCodeWithoutRecordingAnything() public {
        Fixture memory fixture = _fixture();

        VM.expectPartialRevert(HellboxPublicationFactory.UnapprovedPrimarySaleCreationCode.selector);
        fixture.factory
            .deployPrimarySale(
                address(fixture.publication),
                type(FactoryPrimarySalePublicationMock).creationCode,
                fixture.constructorArguments
            );

        require(
            fixture.factory.primarySaleByPublication(address(fixture.publication)) == address(0),
            "wrong code registered"
        );
    }

    function testOnlyFactoryOwnerCanDeployAndBindSale() public {
        Fixture memory fixture = _fixture();

        VM.expectRevert();
        VM.prank(OUTSIDER);
        fixture.factory
            .deployPrimarySale(
                address(fixture.publication), type(HellboxPrimarySale).creationCode, fixture.constructorArguments
            );

        require(
            fixture.factory.primarySaleByPublication(address(fixture.publication)) == address(0),
            "outsider registered sale"
        );
    }

    function _fixture() internal returns (Fixture memory fixture) {
        fixture.factory =
            new FactoryPrimarySaleBindingHarness(address(this), keccak256(type(HellboxPrimarySale).creationCode));
        require(
            fixture.factory.approvedPrimarySaleCreationCodeHash() == keccak256(type(HellboxPrimarySale).creationCode),
            "approved sale hash"
        );

        fixture.phases = _freePhases();
        fixture.commitments = _commitments(fixture.phases);
        fixture.publication =
            new FactoryPrimarySalePublicationMock(address(fixture.factory), keccak256(abi.encode(fixture.commitments)));
        fixture.factory.registerPublicationForTest(address(fixture.publication));

        fixture.constructorArguments =
            abi.encode(address(fixture.publication), address(0), false, fixture.commitments, fixture.phases);
    }

    function _freePhases() internal pure returns (HellboxPrimarySale.Phase[] memory phases) {
        phases = new HellboxPrimarySale.Phase[](1);
        phases[0] = HellboxPrimarySale.Phase({
            phaseId: FREE_PHASE,
            startAt: 0,
            endAt: 0,
            phaseCap: 100,
            phaseWalletCap: 1,
            pricingMode: HellboxPrimarySale.PricingMode.FREE,
            token: address(0),
            exactAmount: 0,
            merkleRoot: bytes32(0)
        });
    }

    function _commitments(HellboxPrimarySale.Phase[] memory phases)
        internal
        pure
        returns (HellboxPrimarySale.PublicationCommitmentSet memory commitments)
    {
        (bytes32 pricingDigest, bytes32 routesDigest, bytes32 phasesDigest) = _policyDigests(phases);

        commitments = HellboxPrimarySale.PublicationCommitmentSet({
            publicationManifestDigest: keccak256("publication-manifest"),
            packageDigest: keccak256("package"),
            fixedCopyRulesDigest: keccak256("fixed-copy-rules"),
            birthTraitsDigest: keccak256("birth-traits"),
            randomizationPolicyDigest: keccak256("randomization-policy"),
            rendererRulesDigest: keccak256("renderer-rules"),
            readerPolicyDigest: keccak256("reader-policy"),
            pricingPoliciesDigest: pricingDigest,
            paymentRoutesDigest: routesDigest,
            mintPhasesDigest: phasesDigest,
            royaltyPolicyDigest: keccak256("royalty-policy"),
            treasuryPolicyDigest: keccak256("treasury-policy"),
            metadataPolicyDigest: keccak256("metadata-policy"),
            capabilityPolicyDigest: keccak256("capability-policy"),
            protocolCompatibilityDigest: keccak256("protocol-compatibility"),
            closurePolicyDigest: keccak256("closure-policy"),
            authorityPolicyDigest: keccak256("authority-policy"),
            eventPolicyDigest: keccak256("event-policy")
        });
    }

    function _policyDigests(HellboxPrimarySale.Phase[] memory phases)
        internal
        pure
        returns (bytes32 pricingDigest, bytes32 routesDigest, bytes32 phasesDigest)
    {
        HellboxPrimarySale.Phase memory phase = phases[0];

        HellboxPrimarySale.PricingCommitment[] memory pricing = new HellboxPrimarySale.PricingCommitment[](1);
        pricing[0] = HellboxPrimarySale.PricingCommitment({
            phaseId: phase.phaseId, pricingMode: phase.pricingMode, exactAmount: phase.exactAmount
        });

        HellboxPrimarySale.PaymentRouteCommitment[] memory routes = new HellboxPrimarySale.PaymentRouteCommitment[](1);
        routes[0] = HellboxPrimarySale.PaymentRouteCommitment({
            phaseId: phase.phaseId,
            pricingMode: phase.pricingMode,
            token: phase.token,
            proceedsReceiver: address(0),
            exactPaymentPolicy: bytes32(0),
            tokenCompatibilityPolicy: bytes32(0)
        });

        HellboxPrimarySale.MintPhaseCommitment[] memory mintPhases = new HellboxPrimarySale.MintPhaseCommitment[](1);
        mintPhases[0] = HellboxPrimarySale.MintPhaseCommitment({
            phaseId: phase.phaseId,
            order: 0,
            startAt: phase.startAt,
            endAt: phase.endAt,
            phaseCap: phase.phaseCap,
            phaseWalletCap: phase.phaseWalletCap,
            merkleRoot: phase.merkleRoot,
            eligibilityLeafSchemaVersion: 0
        });

        pricingDigest = keccak256(abi.encode(keccak256("HELLBOX_ENFORCEMENT_V1:PRICING_POLICIES"), pricing));
        routesDigest = keccak256(abi.encode(keccak256("HELLBOX_ENFORCEMENT_V1:PAYMENT_ROUTES"), routes));
        phasesDigest = keccak256(
            abi.encode(
                keccak256("HELLBOX_ENFORCEMENT_V1:MINT_PHASES"),
                false,
                keccak256("SELF_ONLY"),
                keccak256("DIRECT_EOA"),
                keccak256("SHARED_POOL"),
                keccak256("SHARED_REMAINDER"),
                keccak256("GLOBAL_SHARED"),
                mintPhases
            )
        );
    }
}
