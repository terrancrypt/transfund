// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script} from "forge-std/Script.sol";
import {Engine} from "../src/Engine.sol";

contract DeployEngine is Script {
    Engine engine;

    function run() external {
        vm.startBroadcast();
        engine = new Engine();
        vm.stopBroadcast();
    }
}
