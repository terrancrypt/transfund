// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script} from "forge-std/Script.sol";
import {MockUSDC} from "../test/Mocks/MockUSDC.sol";
import {MockDAI} from "../test/Mocks/MockDAI.sol";
import {MockWBTC} from "../test/Mocks/MockWBTC.sol";
import {MockWETH} from "../test/Mocks/MockWETH.sol";

contract DeployMockToken is Script {
    MockDAI dai;
    MockUSDC usdc;
    MockWBTC wbtc;
    MockWETH weth;

    function run() external {
        vm.startBroadcast();
        dai = new MockDAI(msg.sender);
        usdc = new MockUSDC(msg.sender);
        wbtc = new MockWBTC(msg.sender);
        weth = new MockWETH(msg.sender);
        vm.stopBroadcast();
    }
}
