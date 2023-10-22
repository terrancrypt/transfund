// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC4626Fees} from "../ERC4626/ERC4626Fees.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Fund Vault Contract for TransFund Protocol
/// @author terrancrypt
/// @notice This contract helps the Fund Manager manage their fund, helping to calculate the number of vToken (or shares) deposite and withdraw from the fund.
/// @dev Default token decimals = 18, currently there are no additional features for decimals of each type of ERC20 token.
/// @dev To save time, I use the FundVault contract for direct interaction. This will be change in the future.
contract FundVault is ERC4626Fees {
    /*//////////////////////////////////////////////////////////////
                            Errors
    //////////////////////////////////////////////////////////////*/
    error FundVault__MustBeOwner();
    error FundVault__VaultIsFull();
    error FundVault__OwnerCantWithdraw();
    error FundVault__AddressInvalid();
    error FundVault__TokenInvestNotFound();

    /*//////////////////////////////////////////////////////////////
                            Types
    //////////////////////////////////////////////////////////////*/
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                        State Variables
    //////////////////////////////////////////////////////////////*/
    address payable public immutable i_vaultOwner;
    uint256 public immutable i_ownerSharesPercentage;
    uint256 public immutable i_divideProfits;
    uint256 public s_entryFeeBasicPoints;
    uint256 public s_ownerShares;
    uint256 public s_totalSharesCanMint;

    struct TokenInvest {
        address token;
        address priceFeed;
    }
    mapping(uint256 tokenInvestId => TokenInvest) private s_tokenInvested;
    uint256 private s_currentTokenInvestId;

    /*//////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/
    constructor(
        address _owner,
        IERC20 _asset,
        uint256 _feeBasicPoints,
        uint256 _ownerSharesPercentage,
        uint256 _divideProfits
    ) ERC4626(_asset) ERC20("Vault Trans Fund Token", "vTFT") {
        i_vaultOwner = payable(_owner);
        s_entryFeeBasicPoints = _feeBasicPoints;
        i_ownerSharesPercentage = _ownerSharesPercentage;
        i_divideProfits = _divideProfits;
    }

    /*//////////////////////////////////////////////////////////////
                            Events
    //////////////////////////////////////////////////////////////*/
    event AddTokenInvest(address token, address priceFeed);
    event SwapAssetToTokenInvest(address indexed tokenInvest, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            Modifiers
    //////////////////////////////////////////////////////////////*/
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
            assetsOrShares < _amountOwnerCanWithDraw() &&
            i_ownerSharesPercentage > 0
        ) {
            revert FundVault__OwnerCantWithdraw();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                        Owner Functions
    //////////////////////////////////////////////////////////////*/

    /// @dev priceFeed param will be removed in future, just for summit in ETHOnline
    function addInvestToken(address token, address priceFeed) external {
        if (token == address(0) && priceFeed == (address(0))) {
            revert FundVault__AddressInvalid();
        }

        s_tokenInvested[s_currentTokenInvestId].token = token;
        s_tokenInvested[s_currentTokenInvestId].priceFeed = priceFeed;
        s_currentTokenInvestId++;

        emit AddTokenInvest(token, priceFeed);
    }

    /*//////////////////////////////////////////////////////////////
                        ERC4626 Functions
    //////////////////////////////////////////////////////////////*/
    function deposit(
        uint256 assets,
        address receiver
    ) public virtual override isVaultFull(assets) returns (uint256) {
        require(
            assets <= maxDeposit(receiver),
            "ERC4626: deposit more than max"
        );

        uint256 shares = _calculateSharesToMint(assets);
        shares = previewDeposit(shares);
        _deposit(_msgSender(), receiver, assets, shares);
        _afterDeposit(shares);

        return shares;
    }

    /// @notice This function has not yet been modified or deployed for use due to the limited time of the ETHGlobal Hackathon.
    /// @dev Use function deposit instead.
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

    /// @notice This function has not yet been modified or deployed for use due to the limited time of the ETHGlobal Hackathon.
    /// @dev Use function withdraw instead.
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual override isOwnerCanWithdraw(shares) returns (uint256) {
        require(shares <= maxRedeem(owner), "ERC4626: redeem more than max");

        uint256 assets = previewRedeem(shares);
        _beforeWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        _afterWithdraw(shares);
        return assets;
    }

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
        _beforeWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        _afterWithdraw(assets);
        return shares;
    }

    function _entryFeeBasisPoints() internal view override returns (uint256) {
        return s_entryFeeBasicPoints;
    }

    function _entryFeeRecipient() internal view override returns (address) {
        return i_vaultOwner;
    }

    /*//////////////////////////////////////////////////////////////
                        Hook Functions
    //////////////////////////////////////////////////////////////*/
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

    /// @dev This function has not been implemented yet
    function _beforeWithdraw(uint256 assets) internal virtual {
        // Before withdrawing money, calculate a portion of the interest for the fund's owner, transfer that portion of the interest in the form of vToken to send to the owner
    }

    function _afterWithdraw(uint256 shares) internal virtual {
        if (_msgSender() == i_vaultOwner && i_ownerSharesPercentage > 0) {
            s_ownerShares -= shares;
            s_totalSharesCanMint =
                s_totalSharesCanMint -
                ((shares / i_ownerSharesPercentage) * 100);
        } else {
            s_totalSharesCanMint =
                s_totalSharesCanMint +
                getTotalSharesMinted();
        }
    }

    /*//////////////////////////////////////////////////////////////
                        Internal View Functions
    //////////////////////////////////////////////////////////////*/
    function _amountOwnerCanWithDraw() internal view returns (uint256) {
        if (i_ownerSharesPercentage == 0) {
            return s_ownerShares;
        }

        if (
            _actualOwnerSharesPercentage() > i_ownerSharesPercentage &&
            _actualOwnerSharesPercentage() < 10000
        ) {
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

    function _calculateSharesToMint(
        uint256 amountToDeposit
    ) internal view returns (uint256) {
        if (s_currentTokenInvestId == 0 || getTotalSharesMinted() == 0) {
            return amountToDeposit;
        }
        uint256 totalCapitalOfVault = _calculateTotalCapitalInUSD();
        uint256 totalSharesSupply = getTotalSharesMinted();
        uint256 amountSharesToMint = (amountToDeposit * totalSharesSupply) /
            totalCapitalOfVault;
        return amountSharesToMint;
    }

    function _calculateAmountInUSDToWithdraw(
        uint256 amountSharesToBurn
    ) internal view returns (uint256) {
        if (s_currentTokenInvestId == 0 || getTotalSharesMinted() == 0) {
            return amountSharesToBurn;
        }
        uint256 totalCapitalOfVault = _calculateTotalCapitalInUSD();
        uint256 totalShareSupply = getTotalSharesMinted();
        uint256 amountUSDToWithdraw = (amountSharesToBurn *
            totalCapitalOfVault) / totalShareSupply;
        return amountUSDToWithdraw;
    }

    function _calculateTotalCapitalInUSD() internal view returns (uint256) {
        uint256 totalAmountInUSD = totalAssets();
        for (uint256 i; i < s_currentTokenInvestId; i++) {
            uint256 tokenAmount = IERC20(s_tokenInvested[i].token).balanceOf(
                address(this)
            );
            address priceFeed = s_tokenInvested[i].priceFeed;
            (, int256 answer, , , ) = AggregatorV3Interface(priceFeed)
                .latestRoundData();
            uint256 tokenAmountInUSD = (tokenAmount *
                (uint256(answer) * 1e10)) / 1e18;
            totalAmountInUSD += tokenAmountInUSD;
        }
        return totalAmountInUSD;
    }

    function _calculateSharesRatio(
        address user
    ) internal view returns (uint256) {
        uint256 balanceShares = IERC4626(address(this)).balanceOf(user);
        uint256 ratioInBasisPoint = (balanceShares / getTotalSharesMinted()) *
            10000;
        return ratioInBasisPoint;
    }

    function _totalAmountUserMinted() internal view returns (uint256) {
        return getTotalSharesMinted() - s_ownerShares;
    }

    /*//////////////////////////////////////////////////////////////
                        Getter Functions
    //////////////////////////////////////////////////////////////*/

    function getTotalSharesMinted() public view returns (uint256) {
        return IERC4626(address(this)).totalSupply();
    }

    function getActualOwnerPercentage() public view returns (uint256) {
        return _actualOwnerSharesPercentage();
    }

    function getAmountOwnerCanWithdraw() public view returns (uint256) {
        return _amountOwnerCanWithDraw();
    }

    function getTotalCapitalInVault() public view returns (uint256) {
        return _calculateTotalCapitalInUSD();
    }

    function getAmountInUsdOfToken(
        address token,
        address priceFeed
    ) public view returns (uint256) {
        uint256 tokenAmount = IERC20(token).balanceOf(address(this));
        (, int256 answer, , , ) = AggregatorV3Interface(priceFeed)
            .latestRoundData();
        uint256 tokenAmountInUSD = (tokenAmount * (uint256(answer) * 1e10)) /
            1e18;
        return tokenAmountInUSD;
    }

    function getAmountSharesToMint(
        uint256 amountToDeposit
    ) public view returns (uint256) {
        return _calculateSharesToMint(amountToDeposit);
    }

    function getAmountAssetToWithdraw(
        uint256 amountSharesToBurn
    ) public view returns (uint256) {
        return _calculateAmountInUSDToWithdraw(amountSharesToBurn);
    }
}
