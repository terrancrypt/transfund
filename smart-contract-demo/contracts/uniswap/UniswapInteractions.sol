// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UniswapInteractions is Ownable {
    using SafeERC20 for IERC20;

    address private immutable i_uniswapV3Factory;
    address private immutable i_nonfungiblePositionManager;

    constructor(
        address _uniswapV3Factory,
        address _nonfungiblePositionManager
    ) {
        i_uniswapV3Factory = _uniswapV3Factory;
        i_nonfungiblePositionManager = _nonfungiblePositionManager;
    }

    function deployPool(
        address token0,
        address token1,
        uint24 fee,
        uint160 price
    ) external onlyOwner returns (address poolAddress) {
        INonfungiblePositionManager(i_nonfungiblePositionManager)
            .createAndInitializePoolIfNecessary(token0, token1, fee, price);

        poolAddress = getPoolAddress(token0, token1, fee);
    }

    function addLiquidity(
        address poolAddress,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1,
        uint256 amount0Min,
        uint256 amount1Min,
        address recipient,
        uint256 deadline
    ) external onlyOwner {
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        INonfungiblePositionManager nonfungiblePositionManager = INonfungiblePositionManager(
                i_nonfungiblePositionManager
            );

        IERC20(pool.token0()).safeApprove(poolAddress, amount0);
        IERC20(pool.token1()).safeApprove(poolAddress, amount1);
        IERC20(pool.token0()).safeTransferFrom(
            msg.sender,
            address(this),
            amount0
        );
        IERC20(pool.token1()).safeTransferFrom(
            msg.sender,
            address(this),
            amount1
        );
    }

    function _getPoolData(
        address poolAddress
    )
        internal
        view
        returns (
            int24 tickSpacing,
            uint24 fee,
            uint128 liquidity,
            uint160 sqrtPriceX96,
            int24 tick
        )
    {
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        tickSpacing = pool.tickSpacing();
        fee = pool.fee();
        liquidity = pool.liquidity();
        (sqrtPriceX96, tick, , , , , ) = pool.slot0();
    }

    function getPoolAddress(
        address token0,
        address token1,
        uint24 fee
    ) public view returns (address poolAddress) {
        poolAddress = IUniswapV3Factory(i_uniswapV3Factory).getPool(
            token0,
            token1,
            fee
        );
    }
}
