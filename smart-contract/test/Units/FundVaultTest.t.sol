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

    modifier investorDeepositedToVault() {
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
        assert(FUND_MANAGER_AMOUNT == fundVault.s_ownerShares());
    }

    function testCanDepositToFundVault() public investorDeepositedToVault {
        uint256 investorBalance = IERC4626(fundVault).balanceOf(investor);
        console.log("Investor Balance: ", investorBalance);
        uint256 feeOnTotal = FAUCET_AMOUNT.mulDiv(
            FEE_BASIS_POINT,
            FEE_BASIS_POINT + _BASIS_POINT_SCALE,
            Math.Rounding.Ceil
        );
        console.log("Fee on Total: ", feeOnTotal);
        uint256 vaultTotalSupply = IERC4626(fundVault).totalSupply();

        assert(FAUCET_AMOUNT - feeOnTotal == investorBalance);
        assert(vaultTotalSupply == investorBalance);
    }

    function testGetTotalSharesCanMint() public fundManagerDepositToVault {
        uint256 investorSharesPercentage = 100 - FUND_MANAGER_SHARES_PERCENTAGE;
        uint256 ownerShares = fundVault.s_ownerShares();
        console.log("Total Owner Shares", ownerShares);
        uint256 totalSharesCanMint = (ownerShares * investorSharesPercentage) /
            100;

        uint256 totalSharesCanMintExpected = fundVault.getAmountSharesCanMint();
        console.log("Total Shares Can Deposit", totalSharesCanMintExpected);

        assert(totalSharesCanMint == totalSharesCanMintExpected);
    }
}
