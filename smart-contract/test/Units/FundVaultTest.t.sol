// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {FundVault} from "../../src/Vault/FundVault.sol";
import {MockUSDC} from "../Mocks/MockUSDC.sol";
import {MockWETH} from "../Mocks/MockWETH.sol";
import {MockWBTC} from "../Mocks/MockWBTC.sol";
import {MockV3Aggregator} from "../Mocks/MockV3Aggregator.sol";
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
    MockWETH public weth;
    MockWBTC public wbtc;
    MockV3Aggregator public wethPriceFeed;
    MockV3Aggregator public wbtcPriceFeed;

    uint256 private constant FAUCET_AMOUNT = 100e18;
    uint256 private constant _BASIS_POINT_SCALE = 1e4;
    uint256 private constant FEE_BASIS_POINT = 100;
    uint256 private constant FUND_MANAGER_SHARES_PERCENTAGE = 5;
    uint256 private constant FUND_MANAGER_AMOUNT = 10000e18; // 10,000 usdc
    uint256 private constant DIVIDE_PROFITS = 20; // 20%
    uint256 private constant AMOUNT_MINT_MOCK_TOKEN = 10e18; // 10 WETH, WBTC
    uint8 private constant PRICE_FEED_DECIMALS = 8;

    function setUp() external {
        (fundManager, fundManagerKey) = makeAddrAndKey("fundManager");
        vm.startBroadcast(fundManagerKey);
        usdc = new MockUSDC(fundManager);
        weth = new MockWETH(fundManager);
        wbtc = new MockWBTC(fundManager);
        fundVault = new FundVault(
            fundManager,
            usdc,
            FEE_BASIS_POINT,
            FUND_MANAGER_SHARES_PERCENTAGE,
            DIVIDE_PROFITS
        );

        int256 ETH_USD_PRICE = 1600e8; // $1,600 per ETH
        int256 BTC_USD_PRICE = 25000e8; // $25,000 per BTC
        wethPriceFeed = new MockV3Aggregator(
            PRICE_FEED_DECIMALS,
            ETH_USD_PRICE
        );
        wbtcPriceFeed = new MockV3Aggregator(
            PRICE_FEED_DECIMALS,
            BTC_USD_PRICE
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

        uint256 vaultAssetAmount = fundVault.totalAssets();
        uint256 vaultSharesSupply = fundVault.totalSupply();

        console.log(
            "Fund Manager Deposite, Amount Of Asset: ",
            vaultAssetAmount
        );
        console.log(
            "Amount Shares Supply After Fund Manager Deposit: ",
            vaultSharesSupply
        );
        _;
    }

    modifier investorDepositToVault() {
        vm.startPrank(investor);
        usdc.approve(address(fundVault), FAUCET_AMOUNT);
        fundVault.deposit(FAUCET_AMOUNT, investor);
        vm.stopPrank();

        uint256 vaultAssetAmount = fundVault.totalAssets();
        uint256 investorSharesAmount = IERC4626(address(fundVault)).balanceOf(
            investor
        );
        console.log("Investor Deposited, Amount Of Asset: ", vaultAssetAmount);
        console.log("Investor Shares After Deposit: ", investorSharesAmount);
        _;
    }

    modifier vaultDepositedAndInvested() {
        vm.startPrank(fundManager);
        usdc.mint(FUND_MANAGER_AMOUNT);
        usdc.approve(address(fundVault), FUND_MANAGER_AMOUNT);
        fundVault.deposit(FUND_MANAGER_AMOUNT, fundManager);
        vm.stopPrank();

        vm.startPrank(investor);
        usdc.approve(address(fundVault), FAUCET_AMOUNT);
        fundVault.deposit(FAUCET_AMOUNT, investor);
        vm.stopPrank();
        _;
    }

    modifier vaultIncreaseCapital() {
        vm.startPrank(fundManager);
        weth.mint(AMOUNT_MINT_MOCK_TOKEN);
        wbtc.mint(AMOUNT_MINT_MOCK_TOKEN);

        fundVault.addInvestToken(address(weth), address(wethPriceFeed));
        fundVault.addInvestToken(address(wbtc), address(wbtcPriceFeed));

        weth.approve(address(fundVault), AMOUNT_MINT_MOCK_TOKEN);
        wbtc.approve(address(fundVault), AMOUNT_MINT_MOCK_TOKEN);

        IERC20(address(weth)).transfer(
            address(fundVault),
            AMOUNT_MINT_MOCK_TOKEN
        );
        IERC20(address(wbtc)).transfer(
            address(fundVault),
            AMOUNT_MINT_MOCK_TOKEN
        );
        vm.stopPrank();

        uint256 wethInVault = IERC20(address(weth)).balanceOf(
            address(fundVault)
        );
        uint256 wbtcInVault = IERC20(address(wbtc)).balanceOf(
            address(fundVault)
        );

        console.log(
            "Vault Capital Increase, WETH Amount In Vault: ",
            wethInVault
        );
        console.log("WBTC Amount In Vault: ", wbtcInVault);

        console.log("Total Assets In Vault: ", fundVault.totalAssets());
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

    function testGetCalculateCapitalInVault()
        public
        fundManagerDepositToVault
        investorDepositToVault
        vaultIncreaseCapital
    {
        uint256 capital = fundVault.getTotalCapitalInVault();

        console.log("Capital In Vault", capital);
    }

    function testGetAmountInUSDOfToken() public vaultIncreaseCapital {
        uint256 amountTokenInUSD = fundVault.getAmountInUsdOfToken(
            address(weth),
            address(wethPriceFeed)
        );
        console.log("Amount In USD Of WETH", amountTokenInUSD);
    }

    function testGetAmountSharesToMintAndBurn()
        public
        fundManagerDepositToVault
        investorDepositToVault
        vaultIncreaseCapital
    {
        uint256 totalCapitalInVault = fundVault.getTotalCapitalInVault();
        uint256 amountSharesToMint = fundVault.getAmountSharesToMint(5000e18);
        uint256 vaultTotalSupply = fundVault.totalAssets();
        uint256 expectedAmountShares = (5000e18 * vaultTotalSupply) /
            totalCapitalInVault;
        console.log("Total Capital In Vault", totalCapitalInVault);
        console.log(
            "Amount Shares To Mint After Vault Increase Capital",
            amountSharesToMint
        );
        console.log("Expected Amount Shares To Mint", expectedAmountShares);

        assert(expectedAmountShares == amountSharesToMint);

        uint256 vaultTotalCapitalAfter = totalCapitalInVault + 5000e18;
        uint256 vaultTotalSupplyAfter = vaultTotalSupply + amountSharesToMint;

        console.log(
            "Vault Total Capital After Deposit",
            vaultTotalCapitalAfter
        );
        console.log("Vault Total Supply After Deposit", vaultTotalSupplyAfter);
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
