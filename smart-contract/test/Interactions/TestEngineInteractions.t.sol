// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.21;

// import {Test, console} from "forge-std/Test.sol";
// import {Engine} from "../../src/Engine.sol";
// import {FundVault} from "../../src/Vault/FundVault.sol";
// import {MockUSDC} from "../Mocks/MockUSDC.sol";
// import {ISwapRouter} from "../../src/Interfaces/ISwapRouter.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

// contract TestEngineInteraction is Test {
//     address owner;
//     uint256 privateKey;
//     address investor = makeAddr("investor");
//     address fundManager;
//     uint256 fundManagerPK;
//     Engine engine;
//     FundVault vault;
//     MockUSDC usdc;
//     ISwapRouter swapRouter =
//         ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

//     uint256 constant USDC_OF_FUND_MANAGER = 10000e18; // 10,000 usdc

//     function setUp() external {
//         (owner, privateKey) = makeAddrAndKey("owner");
//         (fundManager, fundManagerPK) = makeAddrAndKey("fundManager");

//         vm.startBroadcast(fundManagerPK);
//         usdc = new MockUSDC(fundManager);
//         usdc.mint(USDC_OF_FUND_MANAGER);
//         vm.stopBroadcast();

//         vm.startBroadcast(privateKey);
//         engine = new Engine(swapRouter);
//         engine.addAssets(IERC20(usdc));
//         vm.stopBroadcast();

//         vm.startPrank(fundManager);
//         address fundVault = engine.createFundVault(IERC20(usdc), 0, 0, 0);
//         vault = FundVault(fundVault);
//         IERC20(address(usdc)).approve(address(engine), USDC_OF_FUND_MANAGER);
//         engine.depositToVault(address(fundVault), USDC_OF_FUND_MANAGER);
//         vm.stopPrank();
//     }

//     function testCanFundManagerDepositToVault() public view {
//         uint256 balanceShares = IERC4626(address(vault)).balanceOf(fundManager);
//         console.log(
//             "Fund Manager Balance Shares After Deposit: ",
//             balanceShares
//         );
//     }
// }
