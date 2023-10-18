// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {FundVault} from "./Vault/FundVault.sol";

contract Engine is AccessControl {
    /*//////////////////////////////////////////////////////////////
                            Errors
    //////////////////////////////////////////////////////////////*/
    error Engine__InvalidAddress();
    error Engine__AssetExisted(address);
    error Engine__AssetNotExist();

    /*//////////////////////////////////////////////////////////////
                        State Variables
    //////////////////////////////////////////////////////////////*/
    mapping(uint24 assetId => IERC20 asset) private s_assets;
    uint24 private s_currentAssetId;
    mapping(IERC20 asset => bool) private s_assetExist;

    /*//////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                            Events
    //////////////////////////////////////////////////////////////*/
    event AddAsset(address assetAddress);
    event FundVaultCreated(address vaultAddress, address indexed owner);

    /*//////////////////////////////////////////////////////////////
                            Modifiers
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                        Owner Functions
    //////////////////////////////////////////////////////////////*/
    function addAssets(IERC20 asset) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(asset) == address(0)) {
            revert Engine__InvalidAddress();
        }
        if (s_assetExist[asset] == true) {
            revert Engine__AssetExisted(address(asset));
        }

        s_assets[s_currentAssetId] = asset;
        s_assetExist[asset] = true;

        emit AddAsset(address(asset));
    }

    function createFundVault(
        IERC20 asset,
        uint256 basicPoints
    ) external returns (address) {
        _isAssetExisted(asset);
        FundVault fundVault = new FundVault(asset, basicPoints);
        emit FundVaultCreated(address(fundVault), msg.sender);
        return address(fundVault);
    }

    /*//////////////////////////////////////////////////////////////
                        Internal View Functions
    //////////////////////////////////////////////////////////////*/
    function _isAssetExisted(IERC20 asset) internal view {
        if (s_assetExist[asset] == false) {
            revert Engine__AssetNotExist();
        }
    }

    /*//////////////////////////////////////////////////////////////
                        Getter Functions
    //////////////////////////////////////////////////////////////*/
    function getAssetExisted(IERC20 asset) public view returns (bool) {
        _isAssetExisted(asset);
        return true;
    }
}
