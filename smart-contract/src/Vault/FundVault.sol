// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC4626Fees} from "../ERC4626/ERC4626Fees.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract FundVault is ERC4626Fees {
    error FundVault__MustBeOwner();

    address payable public immutable i_vaultOwner;
    uint256 public s_entryFeeBasicPoints;
    uint256 public s_ownerShares;
    uint256 private immutable i_ownerSharesPercentage;

    constructor(
        IERC20 _asset,
        uint256 _basicPoints,
        uint256 _ownerSharesPercentage
    ) ERC4626(_asset) ERC20("Vault Trans Fund Token", "vTFT") {
        i_vaultOwner = payable(msg.sender);
        s_entryFeeBasicPoints = _basicPoints;
        i_ownerSharesPercentage = _ownerSharesPercentage;
    }

    /**
     * @param assets amount asset to deposit
     * @param receiver who is receive vToken
     */
    function deposit(
        uint256 assets,
        address receiver
    ) public virtual override returns (uint256) {
        require(
            assets <= maxDeposit(receiver),
            "ERC4626: deposit more than max"
        );

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);
        _afterDeposit(assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-mint}. */
    function mint(
        uint256 shares,
        address receiver
    ) public virtual override returns (uint256) {
        require(shares <= maxMint(receiver), "ERC4626: mint more than max");

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);
        _afterDeposit(assets, shares);

        return assets;
    }

    /** @dev See {IERC4626-redeem}. */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual override returns (uint256) {
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
    ) public virtual override returns (uint256) {
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

    function _amountSharesCanMint() internal view returns (uint256) {
        uint256 investorSharesPercentage = 100 - i_ownerSharesPercentage;
        uint256 amountSharesCanMint = (s_ownerShares *
            investorSharesPercentage) / 100;
        return amountSharesCanMint;
    }

    function _afterDeposit(uint256 assets, uint256 shares) internal virtual {
        if (msg.sender == i_vaultOwner) {
            s_ownerShares += shares;
        }
    }

    function _beforeWithdraw(uint256 assets, uint256 shares) internal virtual {
        // trước khi rút tiền, tính toán một phần tiền lãi cho owner của fund, chuyển phần tiền lãi đó dưới dạng vToken để gửi cho owner
    }

    function getTotalSharesMinted() public view returns (uint256) {
        return IERC20(address(this)).totalSupply();
    }
}
