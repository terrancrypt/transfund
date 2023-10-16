// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/*
 * @title Fund Manager Vault
 * @author terrancrypt
 * @notice This contract helps people become fund managers and helps people
 * participate in open funds through this vault.
 */
contract FundManagerVault is AccessControl {
    // ===== Variables =====
    bytes32 private constant FUND_MANAGER_ROLE = keccak256("FUND_MANAGER_ROLE");
    bytes32 private constant INVESTOR_ROLE = keccak256("INVESTOR_ROLE");

    // ===== Constructor =====
    constructor() {
        _grantRole(FUND_MANAGER_ROLE, msg.sender); // Fund manager who create this contract
    }
}
