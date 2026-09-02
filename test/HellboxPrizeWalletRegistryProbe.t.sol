// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {HellboxBirthPolicy} from "../contracts/HellboxBirthPolicy.sol";
import {HellboxBirthPolicyCodeStore} from "../contracts/HellboxBirthPolicyCodeStore.sol";
import {HellboxPublication} from "../contracts/HellboxPublication.sol";
import {HellboxPublicationFactory} from "../contracts/HellboxPublicationFactory.sol";

interface IVmPrizeRegistry {
    function addr(uint256 privateKey) external returns (address);

    function sign(
        uint256 privateKey,
        bytes32 digest
    ) external returns (uint8 v, bytes32 r, bytes32 s);

    function expectPartialRevert(bytes4 revertData) external;

    function prank(address msgSender) external;

    function warp(uint256 newTimestamp) external;

    function etch(address target, bytes calldata newRuntimeBytecode) external;
}

contract PrizeWalletPublicationActor {
    function reserve(
        HellboxPublicationFactory factory
    )
        external
        returns (
            uint256 generation,
            address wallet,
            bytes32 campaignManifestDigest
        )
    {
        return factory.reserveActivePrizeWalletDeposit();
    }

    function complete(HellboxPublicationFactory factory) external {
        factory.completePrizeWalletDeposit();
    }
}

contract PrizeWalletFactoryHarness is HellboxPublicationFactory {
    constructor(
        address initialOwner,
        bytes32 publicationCreationCodeHash,
        address codeStore,
        bytes32 birthPolicyCreationCodeHash
    )
        HellboxPublicationFactory(
            initialOwner,
            publicationCreationCodeHash,
            codeStore,
            birthPolicyCreationCodeHash
        )
    {}

    function registerPublicationForTest(address publication) external {
        require(msg.sender == owner(), "owner");
        isPublication[publication] = true;
    }
}

contract HellboxPrizeWalletRegistryProbeTest {
    IVmPrizeRegistry internal constant VM =
        IVmPrizeRegistry(
            address(uint160(uint256(keccak256("hevm cheat code"))))
        );

    uint256 internal constant FIRST_WALLET_KEY = 0xA11CE;
    uint256 internal constant SECOND_WALLET_KEY = 0xB0B;
    uint256 internal constant WRONG_WALLET_KEY = 0xBAD;

    bytes32 internal constant FIRST_MANIFEST =
        keccak256("hellbox-prize-campaign-001");
    bytes32 internal constant SECOND_MANIFEST =
        keccak256("hellbox-prize-campaign-002");

    function testFreshWalletSelfSignatureActivatesCampaign() public {
        PrizeWalletFactoryHarness factory = _newFactory();
        address wallet = VM.addr(FIRST_WALLET_KEY);
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = _activationSignature(
            factory,
            FIRST_WALLET_KEY,
            1,
            wallet,
            FIRST_MANIFEST,
            deadline
        );

        uint256 generation = factory.activatePrizeWalletCampaign(
            wallet,
            FIRST_MANIFEST,
            deadline,
            signature
        );

        require(generation == 1, "generation");
        require(factory.activePrizeWalletGeneration() == 1, "active gen");
        require(factory.activePrizeWallet() == wallet, "active wallet");
        require(factory.isActivePrizeWallet(wallet), "active status");
        require(
            factory.prizeWalletGenerationByAddress(wallet) == 1,
            "wallet generation"
        );
        require(
            factory.prizeWalletGenerationByManifestDigest(
                FIRST_MANIFEST
            ) == 1,
            "manifest generation"
        );
        require(
            factory.activePrizeWalletManifestDigest() == FIRST_MANIFEST,
            "manifest"
        );
        require(!factory.activePrizeWalletClaimed(), "claimed");
        require(
            factory.activePrizeWalletPendingDeposits() == 0,
            "pending"
        );

        (
            address storedWallet,
            bytes32 storedManifest,
            uint64 activatedAt,
            uint64 claimedAt,
            uint64 pendingDeposits,
            uint64 completedDeposits
        ) = factory.prizeWalletCampaignByGeneration(1);

        require(storedWallet == wallet, "stored wallet");
        require(storedManifest == FIRST_MANIFEST, "stored manifest");
        require(activatedAt == uint64(block.timestamp), "activated at");
        require(claimedAt == 0, "claimed at");
        require(pendingDeposits == 0, "stored pending");
        require(completedDeposits == 0, "stored completed");
    }

    function testActivationRejectsWrongSignerAndExpiredAuthorization()
        public
    {
        PrizeWalletFactoryHarness factory = _newFactory();
        address wallet = VM.addr(FIRST_WALLET_KEY);
        uint256 deadline = block.timestamp + 1 days;

        bytes memory wrongSignature = _activationSignature(
            factory,
            WRONG_WALLET_KEY,
            1,
            wallet,
            FIRST_MANIFEST,
            deadline
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .PrizeWalletActivationSignatureMismatch
                .selector
        );
        factory.activatePrizeWalletCampaign(
            wallet,
            FIRST_MANIFEST,
            deadline,
            wrongSignature
        );

        bytes memory validSignature = _activationSignature(
            factory,
            FIRST_WALLET_KEY,
            1,
            wallet,
            FIRST_MANIFEST,
            deadline
        );

        VM.warp(deadline + 1);
        VM.expectPartialRevert(
            HellboxPublicationFactory.PrizeWalletAuthorizationExpired.selector
        );
        factory.activatePrizeWalletCampaign(
            wallet,
            FIRST_MANIFEST,
            deadline,
            validSignature
        );
    }

    function testActivationSignatureCannotReplayAcrossFactories() public {
        PrizeWalletFactoryHarness firstFactory = _newFactory();
        PrizeWalletFactoryHarness secondFactory = _newFactory();
        address wallet = VM.addr(FIRST_WALLET_KEY);
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = _activationSignature(
            firstFactory,
            FIRST_WALLET_KEY,
            1,
            wallet,
            FIRST_MANIFEST,
            deadline
        );

        firstFactory.activatePrizeWalletCampaign(
            wallet,
            FIRST_MANIFEST,
            deadline,
            signature
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .PrizeWalletActivationSignatureMismatch
                .selector
        );
        secondFactory.activatePrizeWalletCampaign(
            wallet,
            FIRST_MANIFEST,
            deadline,
            signature
        );
    }

    function testActivationRejectsUnsafeWalletAndManifestShapes() public {
        PrizeWalletFactoryHarness factory = _newFactory();
        address wallet = VM.addr(FIRST_WALLET_KEY);
        uint256 deadline = block.timestamp + 1 days;

        VM.expectPartialRevert(
            HellboxPublicationFactory.PrizeWalletManifestDigestMissing.selector
        );
        factory.activatePrizeWalletCampaign(
            wallet,
            bytes32(0),
            deadline,
            hex""
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory.InvalidPrizeWalletAddress.selector
        );
        factory.activatePrizeWalletCampaign(
            address(this),
            FIRST_MANIFEST,
            deadline,
            hex""
        );

        PrizeWalletPublicationActor actor =
            new PrizeWalletPublicationActor();

        VM.expectPartialRevert(
            HellboxPublicationFactory.PrizeWalletAddressHasCode.selector
        );
        factory.activatePrizeWalletCampaign(
            address(actor),
            FIRST_MANIFEST,
            deadline,
            hex""
        );

        factory.transferOwnership(wallet);
        VM.expectPartialRevert(
            HellboxPublicationFactory.InvalidPrizeWalletAddress.selector
        );
        factory.activatePrizeWalletCampaign(
            wallet,
            FIRST_MANIFEST,
            deadline,
            hex""
        );
    }

    function testUnclaimedCampaignCannotRotateOrBecomeFactoryOwner()
        public
    {
        PrizeWalletFactoryHarness factory = _newFactory();
        address firstWallet = _activateFirst(factory);
        address secondWallet = VM.addr(SECOND_WALLET_KEY);
        uint256 deadline = block.timestamp + 1 days;

        bytes memory secondSignature = _activationSignature(
            factory,
            SECOND_WALLET_KEY,
            2,
            secondWallet,
            SECOND_MANIFEST,
            deadline
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory.PrizeWalletCampaignNotClaimed.selector
        );
        factory.activatePrizeWalletCampaign(
            secondWallet,
            SECOND_MANIFEST,
            deadline,
            secondSignature
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .OwnershipTransferToPrizeWalletDisabled
                .selector
        );
        factory.transferOwnership(firstWallet);
    }

    function testOnlyOfficialPublicationCanReserveAndCompleteExactlyOnce()
        public
    {
        PrizeWalletFactoryHarness factory = _newFactory();
        address wallet = _activateFirst(factory);
        PrizeWalletPublicationActor publication =
            new PrizeWalletPublicationActor();

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .UnauthorizedPrizeWalletPublication
                .selector
        );
        publication.reserve(factory);

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .UnauthorizedPrizeWalletPublication
                .selector
        );
        publication.complete(factory);

        factory.registerPublicationForTest(address(publication));

        VM.expectPartialRevert(
            HellboxPublicationFactory.PrizeWalletPublicationNotApproved.selector
        );
        publication.reserve(factory);

        uint256 approvedGeneration =
            factory.approvePrizeWalletPublication(address(publication));
        require(approvedGeneration == 1, "approved generation");
        require(
            factory.prizeWalletApprovedGenerationByPublication(
                address(publication)
            ) == 1,
            "approval state"
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .PrizeWalletPublicationApprovalAlreadySet
                .selector
        );
        factory.approvePrizeWalletPublication(address(publication));

        factory.revokePrizeWalletPublicationApproval(
            address(publication)
        );
        require(
            factory.prizeWalletApprovedGenerationByPublication(
                address(publication)
            ) == 0,
            "approval not revoked"
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory.PrizeWalletPublicationNotApproved.selector
        );
        publication.reserve(factory);

        factory.approvePrizeWalletPublication(address(publication));

        VM.expectPartialRevert(
            HellboxPublicationFactory.PrizeWalletDepositNotReserved.selector
        );
        publication.complete(factory);

        (
            uint256 generation,
            address reservedWallet,
            bytes32 manifest
        ) = publication.reserve(factory);

        require(generation == 1, "generation");
        require(reservedWallet == wallet, "wallet");
        require(manifest == FIRST_MANIFEST, "manifest");
        require(
            factory.prizeWalletDepositGenerationByPublication(
                address(publication)
            ) == 1,
            "deposit generation"
        );
        require(
            factory.prizeWalletDepositStateByPublication(
                address(publication)
            ) == factory.PRIZE_DEPOSIT_RESERVED(),
            "reserved state"
        );
        require(
            factory.activePrizeWalletPendingDeposits() == 1,
            "pending count"
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .PrizeWalletDepositAlreadyInitialized
                .selector
        );
        publication.reserve(factory);

        publication.complete(factory);

        require(
            factory.prizeWalletDepositStateByPublication(
                address(publication)
            ) == factory.PRIZE_DEPOSIT_COMPLETED(),
            "completed state"
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory.PrizeWalletDepositNotReserved.selector
        );
        publication.complete(factory);
    }

    function testMultiplePublicationsAccumulateInOneActiveCampaign()
        public
    {
        PrizeWalletFactoryHarness factory = _newFactory();
        address wallet = _activateFirst(factory);
        PrizeWalletPublicationActor firstPublication =
            new PrizeWalletPublicationActor();
        PrizeWalletPublicationActor secondPublication =
            new PrizeWalletPublicationActor();

        factory.registerPublicationForTest(address(firstPublication));
        factory.registerPublicationForTest(address(secondPublication));
        factory.approvePrizeWalletPublication(address(firstPublication));
        factory.approvePrizeWalletPublication(address(secondPublication));

        {
            (
                uint256 generation,
                address reservedWallet,
                bytes32 manifest
            ) = firstPublication.reserve(factory);

            require(generation == 1, "first generation");
            require(reservedWallet == wallet, "first wallet");
            require(manifest == FIRST_MANIFEST, "first manifest");
        }
        {
            (
                uint256 generation,
                address reservedWallet,
                bytes32 manifest
            ) = secondPublication.reserve(factory);

            require(generation == 1, "second generation");
            require(reservedWallet == wallet, "second wallet");
            require(manifest == FIRST_MANIFEST, "second manifest");
        }
        require(
            factory.activePrizeWalletPendingDeposits() == 2,
            "two pending"
        );

        firstPublication.complete(factory);
        require(
            factory.activePrizeWalletPendingDeposits() == 1,
            "one pending"
        );

        secondPublication.complete(factory);

        (
            address storedWallet,
            bytes32 storedManifest,
            uint64 activatedAt,
            uint64 claimedAt,
            uint64 pendingDeposits,
            uint64 completedDeposits
        ) = factory.prizeWalletCampaignByGeneration(1);

        require(storedWallet == wallet, "stored wallet");
        require(storedManifest == FIRST_MANIFEST, "stored manifest");
        require(activatedAt != 0, "activation");
        require(claimedAt == 0, "premature claim");
        require(pendingDeposits == 0, "pending remains");
        require(completedDeposits == 2, "completed accumulation");
        require(
            factory.prizeWalletDepositGenerationByPublication(
                address(firstPublication)
            ) == 1,
            "first deposit generation"
        );
        require(
            factory.prizeWalletDepositGenerationByPublication(
                address(secondPublication)
            ) == 1,
            "second deposit generation"
        );
        require(
            factory.prizeWalletDepositStateByPublication(
                address(firstPublication)
            ) == factory.PRIZE_DEPOSIT_COMPLETED(),
            "first completed"
        );
        require(
            factory.prizeWalletDepositStateByPublication(
                address(secondPublication)
            ) == factory.PRIZE_DEPOSIT_COMPLETED(),
            "second completed"
        );
        require(factory.activePrizeWallet() == wallet, "campaign rotated");
    }

    function testPublicationApprovalCannotLeakIntoNextCampaignGeneration()
        public
    {
        PrizeWalletFactoryHarness factory = _newFactory();
        address firstWallet = _activateFirst(factory);
        PrizeWalletPublicationActor staleApprovedPublication =
            new PrizeWalletPublicationActor();
        PrizeWalletPublicationActor firstCampaignDeposit =
            new PrizeWalletPublicationActor();

        factory.registerPublicationForTest(
            address(staleApprovedPublication)
        );
        factory.registerPublicationForTest(address(firstCampaignDeposit));
        require(
            factory.approvePrizeWalletPublication(
                address(staleApprovedPublication)
            ) == 1,
            "stale approval generation"
        );
        factory.approvePrizeWalletPublication(
            address(firstCampaignDeposit)
        );
        firstCampaignDeposit.reserve(factory);
        firstCampaignDeposit.complete(factory);

        VM.prank(firstWallet);
        factory.confirmPrizeWalletClaim();

        address secondWallet = _activateSecond(factory);

        require(
            factory.prizeWalletApprovedGenerationByPublication(
                address(staleApprovedPublication)
            ) == 1,
            "historical approval"
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .PrizeWalletPublicationNotApproved
                .selector
        );
        staleApprovedPublication.reserve(factory);

        require(
            factory.prizeWalletDepositStateByPublication(
                address(staleApprovedPublication)
            ) == factory.PRIZE_DEPOSIT_NONE(),
            "stale approval mutated deposit"
        );
        require(
            factory.approvePrizeWalletPublication(
                address(staleApprovedPublication)
            ) == 2,
            "rebound approval generation"
        );

        (
            uint256 generation,
            address reservedWallet,
            bytes32 manifest
        ) = staleApprovedPublication.reserve(factory);

        require(generation == 2, "second generation");
        require(reservedWallet == secondWallet, "second wallet");
        require(manifest == SECOND_MANIFEST, "second manifest");
    }

    function testOnlyFactoryOwnerCanManagePrizeWalletPublicationApprovals()
        public
    {
        PrizeWalletFactoryHarness factory = _newFactory();
        _activateFirst(factory);
        PrizeWalletPublicationActor publication =
            new PrizeWalletPublicationActor();
        address attacker = VM.addr(WRONG_WALLET_KEY);

        factory.registerPublicationForTest(address(publication));

        VM.expectPartialRevert(
            bytes4(
                keccak256("OwnableUnauthorizedAccount(address)")
            )
        );
        VM.prank(attacker);
        factory.approvePrizeWalletPublication(address(publication));

        require(
            factory.prizeWalletApprovedGenerationByPublication(
                address(publication)
            ) == 0,
            "unauthorized approval"
        );

        factory.approvePrizeWalletPublication(address(publication));

        VM.expectPartialRevert(
            bytes4(
                keccak256("OwnableUnauthorizedAccount(address)")
            )
        );
        VM.prank(attacker);
        factory.revokePrizeWalletPublicationApproval(
            address(publication)
        );

        require(
            factory.prizeWalletApprovedGenerationByPublication(
                address(publication)
            ) == 1,
            "unauthorized revocation"
        );

        factory.revokePrizeWalletPublicationApproval(
            address(publication)
        );
        require(
            factory.prizeWalletApprovedGenerationByPublication(
                address(publication)
            ) == 0,
            "owner revocation"
        );
    }

    function testRevocationCannotStrandAnExistingReservation() public {
        PrizeWalletFactoryHarness factory = _newFactory();
        _activateFirst(factory);
        PrizeWalletPublicationActor publication =
            new PrizeWalletPublicationActor();

        factory.registerPublicationForTest(address(publication));
        factory.approvePrizeWalletPublication(address(publication));
        publication.reserve(factory);

        factory.revokePrizeWalletPublicationApproval(
            address(publication)
        );

        publication.complete(factory);

        require(
            factory.prizeWalletDepositStateByPublication(
                address(publication)
            ) == factory.PRIZE_DEPOSIT_COMPLETED(),
            "reserved completion stranded"
        );
    }

    function testActiveWalletMustRemainAnEoaWhenDepositIsReserved()
        public
    {
        PrizeWalletFactoryHarness factory = _newFactory();
        address wallet = _activateFirst(factory);
        PrizeWalletPublicationActor publication =
            new PrizeWalletPublicationActor();
        factory.registerPublicationForTest(address(publication));
        factory.approvePrizeWalletPublication(address(publication));

        VM.etch(wallet, hex"00");

        VM.expectPartialRevert(
            HellboxPublicationFactory.PrizeWalletAddressHasCode.selector
        );
        publication.reserve(factory);

        require(
            factory.activePrizeWalletPendingDeposits() == 0,
            "pending mutated"
        );
        require(
            factory.prizeWalletDepositStateByPublication(
                address(publication)
            ) == factory.PRIZE_DEPOSIT_NONE(),
            "state mutated"
        );
    }

    function testPendingDepositBlocksClaimThenCompletionUnlocksClaim()
        public
    {
        PrizeWalletFactoryHarness factory = _newFactory();
        address wallet = _activateFirst(factory);
        PrizeWalletPublicationActor publication =
            new PrizeWalletPublicationActor();
        factory.registerPublicationForTest(address(publication));
        factory.approvePrizeWalletPublication(address(publication));
        publication.reserve(factory);

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .PrizeWalletCampaignHasPendingDeposits
                .selector
        );
        VM.prank(wallet);
        factory.confirmPrizeWalletClaim();

        publication.complete(factory);

        (
            address storedWalletBefore,
            bytes32 storedManifestBefore,
            uint64 activatedAtBefore,
            uint64 claimedAtBefore,
            uint64 pendingDeposits,
            uint64 completedDeposits
        ) = factory.prizeWalletCampaignByGeneration(1);

        require(storedWalletBefore == wallet, "stored wallet before");
        require(
            storedManifestBefore == FIRST_MANIFEST,
            "stored manifest before"
        );
        require(activatedAtBefore != 0, "activation before");
        require(claimedAtBefore == 0, "premature claim");
        require(pendingDeposits == 0, "pending not cleared");
        require(completedDeposits == 1, "completed count");

        VM.prank(wallet);
        factory.confirmPrizeWalletClaim();

        (
            address finalWallet,
            bytes32 finalManifest,
            uint64 finalActivatedAt,
            uint64 claimedAtAfter,
            uint64 finalPendingDeposits,
            uint64 finalCompletedDeposits
        ) = factory.prizeWalletCampaignByGeneration(1);

        require(finalWallet == wallet, "final wallet");
        require(finalManifest == FIRST_MANIFEST, "final manifest");
        require(finalActivatedAt != 0, "final activation");
        require(claimedAtAfter != 0, "claim timestamp");
        require(finalPendingDeposits == 0, "final pending");
        require(finalCompletedDeposits == 1, "final completed");
        require(factory.activePrizeWalletClaimed(), "claim status");
        require(!factory.isActivePrizeWallet(wallet), "inactive claimed");
        require(factory.activePrizeWallet() == address(0), "active getter");
    }

    function testDirectWinnerClaimRequiresCompletedDepositAndAllowsRotation()
        public
    {
        PrizeWalletFactoryHarness factory = _newFactory();
        address firstWallet = _activateFirst(factory);

        VM.expectPartialRevert(
            HellboxPublicationFactory.UnauthorizedPrizeWalletClaim.selector
        );
        factory.confirmPrizeWalletClaim();

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .PrizeWalletCampaignHasNoCompletedDeposits
                .selector
        );
        VM.prank(firstWallet);
        factory.confirmPrizeWalletClaim();

        _completeOneDeposit(factory);

        VM.prank(firstWallet);
        factory.confirmPrizeWalletClaim();

        require(factory.activePrizeWalletClaimed(), "first claimed");
        require(factory.activePrizeWallet() == address(0), "no active wallet");
        require(
            factory.activePrizeWalletManifestDigest() == bytes32(0),
            "no active manifest"
        );

        address secondWallet = VM.addr(SECOND_WALLET_KEY);
        uint256 deadline = block.timestamp + 2 days;
        bytes memory secondSignature = _activationSignature(
            factory,
            SECOND_WALLET_KEY,
            2,
            secondWallet,
            SECOND_MANIFEST,
            deadline
        );

        uint256 generation = factory.activatePrizeWalletCampaign(
            secondWallet,
            SECOND_MANIFEST,
            deadline,
            secondSignature
        );

        require(generation == 2, "second generation");
        require(factory.activePrizeWallet() == secondWallet, "second wallet");
        require(factory.isActivePrizeWallet(secondWallet), "second active");
        require(
            factory.prizeWalletGenerationByAddress(firstWallet) == 1,
            "first history"
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .OwnershipTransferToPrizeWalletDisabled
                .selector
        );
        factory.transferOwnership(firstWallet);
    }

    function testCampaignWalletCannotBeReusedAfterClaim() public {
        PrizeWalletFactoryHarness factory = _newFactory();
        address wallet = _activateFirst(factory);
        _completeOneDeposit(factory);

        VM.prank(wallet);
        factory.confirmPrizeWalletClaim();

        uint256 deadline = block.timestamp + 1 days;
        bytes memory reusedSignature = _activationSignature(
            factory,
            FIRST_WALLET_KEY,
            2,
            wallet,
            SECOND_MANIFEST,
            deadline
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .PrizeWalletAddressAlreadyUsed
                .selector
        );
        factory.activatePrizeWalletCampaign(
            wallet,
            SECOND_MANIFEST,
            deadline,
            reusedSignature
        );
    }

    function testCampaignManifestCannotBeReusedAfterClaim() public {
        PrizeWalletFactoryHarness factory = _newFactory();
        address firstWallet = _activateFirst(factory);
        _completeOneDeposit(factory);

        VM.prank(firstWallet);
        factory.confirmPrizeWalletClaim();

        address secondWallet = VM.addr(SECOND_WALLET_KEY);
        uint256 deadline = block.timestamp + 1 days;
        bytes memory signature = _activationSignature(
            factory,
            SECOND_WALLET_KEY,
            2,
            secondWallet,
            FIRST_MANIFEST,
            deadline
        );

        VM.expectPartialRevert(
            HellboxPublicationFactory
                .PrizeWalletManifestAlreadyUsed
                .selector
        );
        factory.activatePrizeWalletCampaign(
            secondWallet,
            FIRST_MANIFEST,
            deadline,
            signature
        );
    }

    function _newFactory()
        internal
        returns (PrizeWalletFactoryHarness factory)
    {
        HellboxBirthPolicyCodeStore store =
            new HellboxBirthPolicyCodeStore();

        factory = new PrizeWalletFactoryHarness(
            address(this),
            keccak256(type(HellboxPublication).creationCode),
            address(store),
            keccak256(type(HellboxBirthPolicy).creationCode)
        );
    }

    function _activateFirst(
        PrizeWalletFactoryHarness factory
    ) internal returns (address wallet) {
        wallet = VM.addr(FIRST_WALLET_KEY);
        uint256 deadline = block.timestamp + 1 days;
        bytes memory signature = _activationSignature(
            factory,
            FIRST_WALLET_KEY,
            1,
            wallet,
            FIRST_MANIFEST,
            deadline
        );

        factory.activatePrizeWalletCampaign(
            wallet,
            FIRST_MANIFEST,
            deadline,
            signature
        );
    }

    function _activateSecond(
        PrizeWalletFactoryHarness factory
    ) internal returns (address wallet) {
        wallet = VM.addr(SECOND_WALLET_KEY);
        uint256 deadline = block.timestamp + 1 days;
        bytes memory signature = _activationSignature(
            factory,
            SECOND_WALLET_KEY,
            2,
            wallet,
            SECOND_MANIFEST,
            deadline
        );

        factory.activatePrizeWalletCampaign(
            wallet,
            SECOND_MANIFEST,
            deadline,
            signature
        );
    }

    function _completeOneDeposit(
        PrizeWalletFactoryHarness factory
    ) internal {
        PrizeWalletPublicationActor publication =
            new PrizeWalletPublicationActor();
        factory.registerPublicationForTest(address(publication));
        factory.approvePrizeWalletPublication(address(publication));
        publication.reserve(factory);
        publication.complete(factory);
    }

    function _activationSignature(
        HellboxPublicationFactory factory,
        uint256 privateKey,
        uint256 generation,
        address wallet,
        bytes32 manifest,
        uint256 deadline
    ) internal returns (bytes memory) {
        bytes32 digest = factory.prizeWalletActivationDigest(
            generation,
            wallet,
            manifest,
            deadline
        );
        return _sign(privateKey, digest);
    }

    function _sign(
        uint256 privateKey,
        bytes32 digest
    ) internal returns (bytes memory signature) {
        (uint8 v, bytes32 r, bytes32 s) = VM.sign(
            privateKey,
            digest
        );
        signature = abi.encodePacked(r, s, v);
    }
}
