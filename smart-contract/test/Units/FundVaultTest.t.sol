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

    address public vaultOwner; // Fund Manager
    uint256 public vaultOwnerKey;
    address public investor = makeAddr("investor");
    FundVault public fundVault;
    MockUSDC public usdc;

    uint256 private constant FAUCET_AMOUNT = 100e18;
    uint256 private constant _BASIS_POINT_SCALE = 1e4;
    uint256 private constant FEE_BASIS_POINT = 100;

    function setUp() external {
        (vaultOwner, vaultOwnerKey) = makeAddrAndKey("vaultOwner");
        vm.startBroadcast(vaultOwnerKey);
        usdc = new MockUSDC(msg.sender);
        fundVault = new FundVault(usdc, FEE_BASIS_POINT, 5);
        vm.stopBroadcast();

        vm.prank(investor);
        usdc.faucet();
    }

    modifier depositedToVault() {
        vm.startPrank(investor);
        usdc.approve(address(fundVault), FAUCET_AMOUNT);
        fundVault.deposit(FAUCET_AMOUNT, investor);
        vm.stopPrank();
        _;
    }

    function testCanDepositToFundVault() public depositedToVault {
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

    function testGetTotalSharesMinted() public {
        fundVault.getTotalSharesMinted();
    }
}
