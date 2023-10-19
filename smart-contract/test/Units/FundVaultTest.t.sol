// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {FundVault} from "../../src/Vault/FundVault.sol";
import {MockUSDC} from "../Mocks/MockUSDC.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract FundVaultTest is Test {
    using Math for uint256;

    address public fundManager;
    uint256 public fundManagerKey;
    address public investor = makeAddr("investor");
    FundVault public fundVault;
    MockUSDC public usdc;

    uint256 private constant FAUCET_AMOUNT = 100e18;
    uint256 private constant _BASIS_POINT_SCALE = 1e4;
    uint256 private constant FEE_BASIS_POINT = 100;
    uint256 private constant FUND_MANAGER_SHARES_PERCENTAGE = 5;
    uint256 private constant FUND_MANAGER_AMOUNT = 10000e18; // 10,000 usdc

    function setUp() external {
        (fundManager, fundManagerKey) = makeAddrAndKey("fundManager");
        vm.startBroadcast(fundManagerKey);
        usdc = new MockUSDC(fundManager);
        fundVault = new FundVault(
            usdc,
            FEE_BASIS_POINT,
            FUND_MANAGER_SHARES_PERCENTAGE
        );
        vm.stopBroadcast();

        vm.prank(investor);
        usdc.faucet();
    }

    modifier fundManagerDepositToVault() {
        vm.startPrank(fundManager);
        usdc.mint(FUND_MANAGER_AMOUNT);
        usdc.approve(address(fundVault), FUND_MANAGER_AMOUNT);
        fundVault.deposit(FUND_MANAGER_AMOUNT, fundManager);
        vm.stopPrank();
        _;
    }

    modifier investorDepositToVault() {
        vm.startPrank(investor);
        usdc.approve(address(fundVault), FAUCET_AMOUNT);
        fundVault.deposit(FAUCET_AMOUNT, investor);
        vm.stopPrank();
        _;
    }

    function testFundManagerCanDepositToFundVault()
        public
        fundManagerDepositToVault
    {
        uint256 fee = _feeOnTotal(FUND_MANAGER_AMOUNT);
        assert(FUND_MANAGER_AMOUNT - fee == fundVault.s_ownerShares());
    }

    function testCanDepositToFundVault()
        public
        fundManagerDepositToVault
        investorDepositToVault
    {
        uint256 investorBalance = IERC4626(fundVault).balanceOf(investor);
        console.log("Investor Balance: ", investorBalance);
        uint256 feeOnTotal = _feeOnTotal(FAUCET_AMOUNT);
        console.log("Fee on Total: ", feeOnTotal);

        assert(FAUCET_AMOUNT - feeOnTotal == investorBalance);
    }

    function testCantDepositIfVaultFull() public {
        vm.startPrank(fundManager);
        usdc.mint(5e18);
        usdc.approve(address(fundVault), 5e18);
        fundVault.deposit(5e18, fundManager);
        vm.stopPrank();

        uint256 ownerShares = fundVault.s_ownerShares();
        console.log("Owner Shares", ownerShares);

        uint256 totalSharesCanMint = fundVault.s_totalSharesCanMint();
        console.log("Total Shares Can Mint", totalSharesCanMint);

        vm.startPrank(investor);
        usdc.faucet();
        usdc.approve(address(fundVault), FAUCET_AMOUNT);
        vm.expectRevert(FundVault.FundVault__VaultIsFull.selector);
        fundVault.deposit(FAUCET_AMOUNT, investor);
        vm.stopPrank();
    }

    function testGetTotalSharesCanMint() public fundManagerDepositToVault {
        uint256 totalSharesCanMintFirst = fundVault.s_totalSharesCanMint();
        console.log("Total Shares First: ", totalSharesCanMintFirst);
        uint256 ownerShares = fundVault.s_ownerShares();
        console.log("Owner Shares: ", ownerShares);

        vm.startPrank(investor);
        usdc.faucet();
        usdc.faucet();
        usdc.approve(address(fundVault), FAUCET_AMOUNT + FAUCET_AMOUNT);
        fundVault.deposit(FAUCET_AMOUNT + FAUCET_AMOUNT, investor);
        vm.stopPrank();

        vm.startPrank(fundManager);
        usdc.mint(FUND_MANAGER_AMOUNT - 5000e18);
        usdc.approve(address(fundVault), FUND_MANAGER_AMOUNT - 5000e18);
        fundVault.deposit(FUND_MANAGER_AMOUNT - 5000e18, fundManager);
        vm.stopPrank();

        uint256 totalSharesCanMintSecond = fundVault.s_totalSharesCanMint();
        console.log("Total Shares Second: ", totalSharesCanMintSecond);
        uint256 ownerSharesSecond = fundVault.s_ownerShares();
        console.log("Owner Shares: ", ownerSharesSecond);

        vm.startPrank(investor);
        usdc.faucet();
        usdc.faucet();
        usdc.approve(address(fundVault), FAUCET_AMOUNT + FAUCET_AMOUNT);
        fundVault.deposit(FAUCET_AMOUNT + FAUCET_AMOUNT, investor);
        vm.stopPrank();

        uint256 totalSharesCanMintThird = fundVault.s_totalSharesCanMint();
        console.log("Total Shares Third", totalSharesCanMintThird);
        uint256 ownerSharesThird = fundVault.s_ownerShares();
        console.log("Owner Shares: ", ownerSharesThird);
    }

    function testGetOwnerActualPercentage()
        public
        fundManagerDepositToVault
        investorDepositToVault
    {
        uint256 totalSharesSupply = fundVault.getTotalSharesMinted();
        console.log("Total Shares Minted: ", totalSharesSupply);

        uint256 fundManagerShares = FUND_MANAGER_AMOUNT -
            _feeOnTotal(FUND_MANAGER_AMOUNT);
        console.log("Fund Manager Shares", fundManagerShares);

        uint256 investorShares = IERC4626(address(fundVault)).balanceOf(
            investor
        );

        console.log("Investor Shares", investorShares);

        assert(
            IERC4626(address(fundVault)).totalSupply() ==
                fundManagerShares + investorShares
        );

        uint256 expectedPercentage = (fundManagerShares * 10000) /
            IERC4626(address(fundVault)).totalSupply();

        console.log("Expected Fund Manager Percentage: ", expectedPercentage);

        uint256 actualPercentage = fundVault.getActualOwnerPercentage();

        console.log(
            "Actual Fund Manager Shares Percentage: ",
            actualPercentage
        );

        assert(expectedPercentage == actualPercentage);
    }

    function testGetAmountOwnerCanWithdraw()
        public
        fundManagerDepositToVault
        investorDepositToVault
    {
        uint256 totalSharesSupply = fundVault.getTotalSharesMinted();

        console.log("Total Shares Minted: ", totalSharesSupply);

        uint256 amountOwnerShares = IERC4626(address(fundVault)).balanceOf(
            fundManager
        );

        console.log("Fund Manager Shares", amountOwnerShares);

        uint256 amountOwnerCanWithdraw = fundVault.getAmountOwnerCanWithdraw();

        console.log("Amount Fund Manager Can Withdraw", amountOwnerCanWithdraw);

        uint256 amountSharesOfOwnerAfterWithdraw = amountOwnerShares -
            amountOwnerCanWithdraw;

        console.log(
            "Amount Shares Of Owner After Withdraw",
            amountSharesOfOwnerAfterWithdraw
        );

        uint256 amountInvestorShares = IERC4626(address(fundVault)).balanceOf(
            investor
        );

        console.log("Amount Investor Shares: ", amountInvestorShares);

        uint256 amountFundManagerMustCommited = (amountInvestorShares *
            FUND_MANAGER_SHARES_PERCENTAGE) / 100;

        console.log(
            "Amount Shares Fund Manager Must Commited",
            amountFundManagerMustCommited
        );

        assert(
            amountSharesOfOwnerAfterWithdraw == amountFundManagerMustCommited
        );
    }

    function _feeOnTotal(uint256 amount) internal pure returns (uint256) {
        return
            amount.mulDiv(
                FEE_BASIS_POINT,
                FEE_BASIS_POINT + _BASIS_POINT_SCALE,
                Math.Rounding.Ceil
            );
    }
}
