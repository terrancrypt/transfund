// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC4626Fees} from "../ERC4626/ERC4626Fees.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract FundVault is ERC4626Fees {
    error FundVault__MustBeOwner();
    error FundVault__VaultIsFull();
    error FundVault__OwnerCantWithdraw();

    address payable public immutable i_vaultOwner;
    uint256 public s_entryFeeBasicPoints;
    uint256 public s_ownerShares;
    uint256 public immutable i_ownerSharesPercentage;
    uint256 public s_totalSharesCanMint;

    constructor(
        IERC20 _asset,
        uint256 _feeBasicPoints,
        uint256 _ownerSharesPercentage
    ) ERC4626(_asset) ERC20("Vault Trans Fund Token", "vTFT") {
        i_vaultOwner = payable(msg.sender);
        s_entryFeeBasicPoints = _feeBasicPoints;
        i_ownerSharesPercentage = _ownerSharesPercentage;
    }

    modifier isVaultFull(uint256 assetsOrShares) {
        if (_msgSender() != i_vaultOwner) {
            if (assetsOrShares > s_totalSharesCanMint) {
                revert FundVault__VaultIsFull();
            }
        }
        _;
    }

    modifier isOwnerCanWithdraw(uint256 assetsOrShares) {
        if (
            _msgSender() == i_vaultOwner &&
            assetsOrShares < _amountOwnerCanWithDraw()
        ) {
            revert FundVault__OwnerCantWithdraw();
        }
        _;
    }

    /**
     * @param assets amount asset to deposit
     * @param receiver who is receive vToken
     */
    function deposit(
        uint256 assets,
        address receiver
    ) public virtual override isVaultFull(assets) returns (uint256) {
        require(
            assets <= maxDeposit(receiver),
            "ERC4626: deposit more than max"
        );

        uint256 shares = previewDeposit(assets);

        _deposit(_msgSender(), receiver, assets, shares);
        _afterDeposit(shares);

        return shares;
    }

    /** @dev See {IERC4626-mint}. */
    function mint(
        uint256 shares,
        address receiver
    ) public virtual override isVaultFull(shares) returns (uint256) {
        require(shares <= maxMint(receiver), "ERC4626: mint more than max");

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);
        _afterDeposit(shares);

        return assets;
    }

    /** @dev See {IERC4626-redeem}. */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual override isOwnerCanWithdraw(shares) returns (uint256) {
        require(shares <= maxRedeem(owner), "ERC4626: redeem more than max");

        uint256 assets = previewRedeem(shares);
        _beforeWithdraw(assets, shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    /** @dev See {IERC4626-withdraw}. */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual override isOwnerCanWithdraw(assets) returns (uint256) {
        require(
            assets <= maxWithdraw(owner),
            "ERC4626: withdraw more than max"
        );

        uint256 shares = previewWithdraw(assets);
        _beforeWithdraw(assets, shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    function _entryFeeBasisPoints() internal view override returns (uint256) {
        return s_entryFeeBasicPoints;
    }

    function _entryFeeRecipient() internal view override returns (address) {
        return i_vaultOwner;
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    // function _isOwnerHasCommitted() internal view returns (bool) {
    //    uint256 sharesBalance = IERC20(address(this)).balanceOf(i_vaultOwner);
    // }

    function _afterDeposit(uint256 shares) internal virtual {
        if (_msgSender() == i_vaultOwner && i_ownerSharesPercentage > 0) {
            s_ownerShares += shares;
            s_totalSharesCanMint =
                (s_totalSharesCanMint +
                    ((shares / i_ownerSharesPercentage) * 100)) -
                shares;
        } else {
            s_totalSharesCanMint =
                s_totalSharesCanMint -
                getTotalSharesMinted();
        }
    }

    function _beforeWithdraw(uint256 assets, uint256 shares) internal virtual {
        // trước khi rút tiền, tính toán một phần tiền lãi cho owner của fund, chuyển phần tiền lãi đó dưới dạng vToken để gửi cho owner
    }

    function _afterWithdraw(uint256 shares) internal virtual {
        if (_msgSender() == i_vaultOwner && i_ownerSharesPercentage > 0) {
            require(shares <= s_ownerShares, "Insufficient owner shares");
            s_ownerShares -= shares;
            s_totalSharesCanMint =
                s_totalSharesCanMint +
                ((shares / i_ownerSharesPercentage) * 100);
        } else {
            s_totalSharesCanMint =
                s_totalSharesCanMint -
                getTotalSharesMinted();
        }
    }

    function _amountOwnerCanWithDraw() internal view returns (uint256) {
        if (i_ownerSharesPercentage == 0) {
            return s_ownerShares;
        }

        if (
            _actualOwnerSharesPercentage() > i_ownerSharesPercentage &&
            _actualOwnerSharesPercentage() < 10000
        ) {
            // uint256 percentageCanWithdraw = _actualOwnerSharesPercentage() -
            //     i_ownerSharesPercentage;

            uint256 amountCanWithdraw = s_ownerShares -
                ((_totalAmountUserMinted() * i_ownerSharesPercentage) / 100);

            return amountCanWithdraw;
        }

        return s_ownerShares;
    }

    function _actualOwnerSharesPercentage()
        internal
        view
        returns (uint256 percentageInBasisPoints)
    {
        percentageInBasisPoints =
            (s_ownerShares * 10000) /
            getTotalSharesMinted();
    }

    function _totalAmountUserMinted() internal view returns (uint256) {
        return getTotalSharesMinted() - s_ownerShares;
    }

    function getTotalSharesMinted() public view returns (uint256) {
        return IERC4626(address(this)).totalSupply();
    }

    function getActualOwnerPercentage() public view returns (uint256) {
        return _actualOwnerSharesPercentage();
    }

    function getAmountOwnerCanWithdraw() public view returns (uint256) {
        return _amountOwnerCanWithDraw();
    }
}
