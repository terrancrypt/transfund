// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract MockLINK is ERC20, Ownable {
    using SafeERC20 for ERC20;

    uint256 private constant MAX_FAUCET_AMOUNT = 100e18; // 100 DAI

    constructor() ERC20("Chainlink", "LINK") {}

    function mint(uint256 _amount) external onlyOwner {
        _mint(msg.sender, _amount);
    }

    function faucet() public {
        _mint(msg.sender, MAX_FAUCET_AMOUNT);
    }
}
