// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MockWETH is ERC20, Ownable {
    uint256 private constant FAUCET_AMOUNT = 100e18; // 100 USDC

    constructor(
        address _initialOwner
    ) ERC20("Wrapped ETH", "WETH") Ownable(_initialOwner) {}

    function mint(uint256 amount) external onlyOwner {
        _mint(msg.sender, amount);
    }

    function faucet() public {
        _mint(msg.sender, FAUCET_AMOUNT);
    }
}
