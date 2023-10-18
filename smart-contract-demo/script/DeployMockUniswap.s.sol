// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {UniswapV3Factory} from "../test/mocks/uniswapV3/core/UniswapV3Factory.sol";
import {SwapRouter} from "../test/mocks/uniswapV3/periphery/SwapRouter.sol";
// import {NFTDescriptor} from "../test/mocks/uniswapV3/periphery/libraries/NFTDescriptor.sol";
import {NonfungiblePositionManager} from "../test/mocks/uniswapV3/periphery/NonfungiblePositionManager.sol";
import {NonfungibleTokenPositionDescriptor} from "../test/mocks/uniswapV3/periphery/NonfungibleTokenPositionDescriptor.sol";
import {WETH9} from "../test/mocks/token/MockWETH9.sol";

/**
 * @title Deploy Mock Uniswap V3
 * @author terrancrypt
 * @notice This Script Contract helps deploy a mock version (or fork) of Uniswap V3 to the local Anvil chain or any other EVM compatible testnet.
 */
contract DeployMockUniswap is Script {
    UniswapV3Factory uniswapV3Factory;
    SwapRouter swapRouter;
    // NFTDescriptor nftDescriptor;
    NonfungibleTokenPositionDescriptor nonfungibleTokenPositionDescriptor;
    NonfungiblePositionManager nonfungiblePositionManager;
    WETH9 mockWETH9;

    bytes32 public constant NATIVE_CURRENCY_LABEL = keccak256("WETH");

    function run() external {
        vm.startBroadcast();
        mockWETH9 = new WETH9();
        uniswapV3Factory = new UniswapV3Factory();
        swapRouter = new SwapRouter(
            address(uniswapV3Factory),
            address(mockWETH9)
        );
        // nftDescriptor = new NFTDescriptor();
        nonfungibleTokenPositionDescriptor = new NonfungibleTokenPositionDescriptor(
            address(mockWETH9),
            NATIVE_CURRENCY_LABEL
        );
        nonfungiblePositionManager = new NonfungiblePositionManager(
            address(uniswapV3Factory),
            address(mockWETH9),
            address(nonfungibleTokenPositionDescriptor)
        );
        vm.stopBroadcast();
    }
}
