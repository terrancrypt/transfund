// // SPDX-License-Identifier: MIT
// pragma solidity ^0.5.0;

// import {WETH9} from "../test/mocks/token/MockWETH9.sol";
// import {Script} from "forge-std/Script.sol";

// contract HelperConfig is Script {
//     NetworkConfig public activeNetworkConfig;

//     uint256 public constant DEFAULT_ANVIL_PRIVATE_KEY =
//         0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

//     struct NetworkConfig {
//         uint256 deployerKey;
//         address mockWETH9Address;
//     }

//     constructor() {
//         if (block.chainid == 1442) {
//             activeNetworkConfig = getPolygonZkEvmConfig();
//         } else {
//             activeNetworkConfig = getAnvilConfig();
//         }
//     }

//     function getPolygonZkEvmConfig() public returns (NetworkConfig memory) {}

//     function getAnvilConfig()
//         public
//         returns (NetworkConfig memory anvilNetworkConfig)
//     {
//         if (activeNetworkConfig.mockDAIAddress != address(0)) {
//             return activeNetworkConfig;
//         }

//         vm.startBroadcast(DEFAULT_ANVIL_PRIVATE_KEY);
//         WETH9 mockWETH = new WETH9(msg.sender);
//         vm.stopBroadcast();

//         anvilNetworkConfig = NetworkConfig({
//             deployerKey: DEFAULT_ANVIL_PRIVATE_KEY,
//             mockWETH9Address: address(mockWETH)
//         });
//     }
// }
