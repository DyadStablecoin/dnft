// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IAggregatorV3} from "./interfaces/IAggregatorV3.sol";

import {ERC20} from "@solmate/src/tokens/ERC20.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "@solmate/src/utils/SafeTransferLib.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract Vault is IVault, ERC20 {
  using FixedPointMathLib for uint;
  using SafeCast          for int;
  using SafeTransferLib   for ERC20;

  ERC20         public immutable asset;
  DNft          public immutable dNft;
  IAggregatorV3 public immutable oracle;

  mapping (uint => uint) public xp; // dNftId => xp
  uint                   public totalXP;

  uint public totalPositions;

  constructor(
      DNft          _dNft,
      IAggregatorV3 _oracle,
      ERC20         _asset,
      string memory _name,
      string memory _symbol
  ) ERC20(_name, _symbol, _asset.decimals()) {
      asset  = _asset;
      dNft   = _dNft;
      oracle = _oracle;
  }

  function deposit(
    uint    dNftId,
    uint    assets,
    address receiver, 
    uint    lockInSeconds
  ) external {
    uint lockSizeUSD = assets.mulWadDown(_collatPrice());
    uint startingXP  = xp[dNftId];
    uint xpGained    = lockSizeUSD.mulWadDown(lockInSeconds);
    xpGained         = xpGained.mulWadDown(uint(1).divWadDown(uint(1) + startingXP.divWadDown(totalXP)));
    xp[dNftId]       = xpGained;
    totalXP         += xpGained;
  }

  function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
      // Check for rounding error since we round down in previewDeposit.
      require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");

      // Need to transfer before minting or ERC777s could reenter.
      asset.safeTransferFrom(msg.sender, address(this), assets);

      _mint(receiver, shares);

      emit Deposit(msg.sender, receiver, assets, shares);
  }

  function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
      assets = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

      // Need to transfer before minting or ERC777s could reenter.
      asset.safeTransferFrom(msg.sender, address(this), assets);

      _mint(receiver, shares);

      emit Deposit(msg.sender, receiver, assets, shares);
  }

  function withdraw(
      uint256 assets,
      address receiver,
      address owner
  ) public virtual returns (uint256 shares) {
      shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.

      if (msg.sender != owner) {
          uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

          if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
      }

      _burn(owner, shares);

      emit Withdraw(msg.sender, receiver, owner, assets, shares);

      asset.safeTransfer(receiver, assets);
  }

  function redeem(
      uint256 shares,
      address receiver,
      address owner
  ) public virtual returns (uint256 assets) {
      if (msg.sender != owner) {
          uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

          if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
      }

      // Check for rounding error since we round down in previewRedeem.
      require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");

      _burn(owner, shares);

      emit Withdraw(msg.sender, receiver, owner, assets, shares);

      asset.safeTransfer(receiver, assets);
  }

  function liquidate() public {}

  function totalAssets() public view returns (uint) {
    return asset.balanceOf(address(this));
  }

  function convertToShares(uint256 assets) public view virtual returns (uint256) {
      uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

      return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
  }

  function convertToAssets(uint256 shares) public view virtual returns (uint256) {
      uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

      return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
  }

  function previewDeposit(uint256 assets) public view virtual returns (uint256) {
      return convertToShares(assets);
  }

  function previewMint(uint256 shares) public view virtual returns (uint256) {
      uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

      return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
  }

  function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
      uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

      return supply == 0 ? assets : assets.mulDivUp(supply, totalAssets());
  }

  function previewRedeem(uint256 shares) public view virtual returns (uint256) {
      return convertToAssets(shares);
  }

  /*//////////////////////////////////////////////////////////////
                   DEPOSIT/WITHDRAWAL LIMIT LOGIC
  //////////////////////////////////////////////////////////////*/

  function maxDeposit(address) public view virtual returns (uint256) {
      return type(uint256).max;
  }

  function maxMint(address) public view virtual returns (uint256) {
      return type(uint256).max;
  }

  function maxWithdraw(address owner) public view virtual returns (uint256) {
      return convertToAssets(balanceOf[owner]);
  }

  function maxRedeem(address owner) public view virtual returns (uint256) {
      return balanceOf[owner];
  }

  // collateral price in USD
  function _collatPrice() 
    private 
    view 
    returns (uint) {
      (
        uint80 roundID,
        int256 price,
        , 
        uint256 timeStamp, 
        uint80 answeredInRound
      ) = oracle.latestRoundData();
      if (timeStamp == 0)            revert IncompleteRound();
      if (answeredInRound < roundID) revert StaleData();
      return price.toUint256();
  }
}
