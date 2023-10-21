// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.21;

// import {Test, console} from "forge-std/Test.sol";
// import {Engine} from "../../src/Engine.sol";
// import {MockUSDC} from "../Mocks/MockUSDC.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

// contract EngineTest is Test {
//     event FundVaultCreated(address vaultAddress, address indexed owner);

//     address public owner;
//     uint256 public ownerPrivateKey;
//     address public fundManager = makeAddr("fundManager");

//     Engine public engine;
//     MockUSDC public usdc;

//     bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
//     uint256 public constant BASIC_POINT = 100; // 1% entry fee

//     function setUp() public {
//         (owner, ownerPrivateKey) = makeAddrAndKey("owner");

//         vm.startBroadcast(ownerPrivateKey);

//         engine = new Engine(address(1));
//         usdc = new MockUSDC(msg.sender);

//         vm.stopBroadcast();
//     }

//     /*//////////////////////////////////////////////////////////////
//                         Modifiers
//     //////////////////////////////////////////////////////////////*/
//     modifier assetsAdded() {
//         vm.prank(owner);
//         engine.addAssets(IERC20(usdc));
//         _;
//     }

//     /*//////////////////////////////////////////////////////////////
//                         Owner Functions
//     //////////////////////////////////////////////////////////////*/
//     function testCanAddAsset() public {
//         vm.prank(owner);
//         engine.addAssets(IERC20(usdc));

//         assert(engine.getAssetExisted(IERC20(usdc)) == true);
//     }

//     function testRevertIfAssetExisted() public assetsAdded {
//         vm.expectRevert(
//             abi.encodeWithSelector(
//                 Engine.Engine__AssetExisted.selector,
//                 address(usdc)
//             )
//         );
//         vm.prank(owner);
//         engine.addAssets(IERC20(usdc));
//     }

//     function testRevertIfNotOwner() public {
//         vm.expectRevert();
//         vm.prank(fundManager);
//         engine.addAssets(IERC20(usdc));
//     }

//     /*//////////////////////////////////////////////////////////////
//                         Fund Manager Functions
//     //////////////////////////////////////////////////////////////*/
//     // function testCanCreateFundVault() public assetsAdded {
//     //     vm.prank(fundManager);
//     //     engine.createFundVault(IERC20(usdc), BASIC_POINT);
//     // }

//     // function testRevertCreateVaultIfAssetNotExist() public {
//     //     vm.expectRevert(Engine.Engine__AssetNotExist.selector);
//     //     vm.prank(fundManager);
//     //     engine.createFundVault(IERC20(usdc), BASIC_POINT);
//     // }
// }
