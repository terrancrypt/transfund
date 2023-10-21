// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "./Interfaces/ISwapRouter.sol";
import {FundVault} from "./Vault/FundVault.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Engine is AccessControl {
    /*//////////////////////////////////////////////////////////////
                            Errors
    //////////////////////////////////////////////////////////////*/
    error Engine__InvalidAddress();
    error Engine__AssetExisted(address);
    error Engine__AssetNotExist();
    error Engine__OnlyFundManager();
    error Engine__NotAllowed();

    /*//////////////////////////////////////////////////////////////
                            Types
    //////////////////////////////////////////////////////////////*/
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                        State Variables
    //////////////////////////////////////////////////////////////*/
    ISwapRouter private immutable i_swapRouter;
    mapping(uint24 assetId => IERC20 asset) private s_assets;
    uint24 private s_currentAssetId;
    mapping(IERC20 asset => bool) private s_assetExist;
    mapping(address fundManager => address fundVault)
        private s_fundVaultOwnership;

    /*//////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/
    constructor(ISwapRouter _swapRouter) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        i_swapRouter = _swapRouter;
    }

    /*//////////////////////////////////////////////////////////////
                            Events
    //////////////////////////////////////////////////////////////*/
    event AddAsset(address assetAddress);
    event FundVaultCreated(address vaultAddress, address indexed owner);

    /*//////////////////////////////////////////////////////////////
                            Modifiers
    //////////////////////////////////////////////////////////////*/
    modifier onlyFundManger(address fundManager) {
        if (s_fundVaultOwnership[fundManager] != address(0)) {
            revert Engine__OnlyFundManager();
        }
        _;
    }

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

    /*//////////////////////////////////////////////////////////////
                        Fund Manger Functions
    //////////////////////////////////////////////////////////////*/
    function createFundVault(
        IERC20 asset,
        uint256 basicPoints,
        uint256 ownerSharesPercentage,
        uint256 divideProfits
    ) external returns (address) {
        _isAssetExisted(asset);
        FundVault fundVault = new FundVault(
            address(this),
            _msgSender(),
            asset,
            basicPoints,
            ownerSharesPercentage,
            divideProfits
        );

        s_fundVaultOwnership[_msgSender()] = address(fundVault);

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
