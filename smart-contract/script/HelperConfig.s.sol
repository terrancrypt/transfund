// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script} from "forge-std/Script.sol";
import {MockDAI} from "../test/mocks/token/MockDAI.sol";
import {MockWETH} from "../test/mocks/token/MockWETH.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint256 public constant DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    struct NetworkConfig {
        uint256 deployerKey;
        address mockDAIAddress;
        address mockWETHAddress;
    }

    constructor() {
        if (block.chainid == 1442) {
            activeNetworkConfig = getPolygonZkEvmConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getPolygonZkEvmConfig() public returns (NetworkConfig memory) {}

    function getAnvilConfig()
        public
        returns (NetworkConfig memory anvilNetworkConfig)
    {
        if (activeNetworkConfig.mockDAIAddress != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast(DEFAULT_ANVIL_PRIVATE_KEY);
        MockDAI mockDai = new MockDAI(msg.sender);
        MockWETH mockWETH = new MockWETH(msg.sender);
        vm.stopBroadcast();

        anvilNetworkConfig = NetworkConfig({
            deployerKey: DEFAULT_ANVIL_PRIVATE_KEY,
            mockDAIAddress: address(mockDai),
            mockWETHAddress: address(mockWETH)
        });
    }
}
