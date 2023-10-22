// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {FundVault} from "./Vault/FundVault.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Engine Contract for Trans Fund Protocol
/// @author terancrypt
/// @notice This contract helps fundManager use it to create FundVault contracts, swap tokens, add liquidity,...
/// @dev The feature to interact with other DeFi protocols has not been implemented, only including adding assets to help Fund Manager create FundVault contracts
contract Engine is AccessControl {
    /*//////////////////////////////////////////////////////////////
                            Errors
    //////////////////////////////////////////////////////////////*/
    error Engine__InvalidAddress();
    error Engine__AssetExisted(address);
    error Engine__AssetNotExist();
    error Engine__OnlyFundManager();
    error Engine__NotAllowed();
    error Engine__FundVaultNotExist();

    /*//////////////////////////////////////////////////////////////
                            Types
    //////////////////////////////////////////////////////////////*/
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                        State Variables
    //////////////////////////////////////////////////////////////*/
    mapping(uint24 assetId => IERC20 asset) private s_assets;
    uint24 private s_currentAssetId;
    mapping(IERC20 asset => bool) private s_assetExist;
    mapping(address fundManager => address fundVault)
        private s_fundVaultOwnership;
    mapping(address fundVault => bool) private s_fundVaultExisted;

    /// @dev this variables will be remove in future, just for summit in ETHOnline
    mapping(uint256 fundVaultId => address fundVault) private s_fundVaults;

    uint256 private s_currentFundVaultId;
    mapping(address investor => address[]) private s_investorDeposited;
    mapping(address investor => mapping(address vault => bool))
        private s_isVaultInvested;

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
    event DepositToVault(
        address indexed user,
        address indexed vaultAddress,
        uint256 amountAssetIn,
        uint256 amountShareMinted
    );

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
            _msgSender(),
            asset,
            basicPoints,
            ownerSharesPercentage,
            divideProfits
        );

        s_fundVaultOwnership[_msgSender()] = address(fundVault);
        s_fundVaultExisted[address(fundVault)] = true;
        s_fundVaults[s_currentFundVaultId] = address(fundVault);
        s_currentFundVaultId++;

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
        if (s_assetExist[asset] == false) {
            return false;
        }
        return true;
    }

    function getFundVaultAddresses() public view returns (address[] memory) {
        uint256 count = s_currentFundVaultId;
        address[] memory addresses = new address[](count);

        for (uint256 i = 0; i < count; i++) {
            addresses[i] = s_fundVaults[i];
        }

        return addresses;
    }
}
