// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ERC20NonTransferable} from "./ERC20.sol";
import {SafeTransferLib} from "@solmate/src/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";

abstract contract ERC4626Custom is ERC20NonTransferable {
  using SafeTransferLib   for ERC20;
  using FixedPointMathLib for uint256;

  event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
  event Withdraw(
      address indexed caller,
      address indexed receiver,
      address indexed owner,
      uint256 assets,
      uint256 shares
  );

  ERC20 public immutable asset;

  constructor(
      ERC20 _asset,
      string memory _name,
      string memory _symbol
  ) ERC20NonTransferable(_name, _symbol, _asset.decimals()) {
      asset = _asset;
  }

  function totalAssets() 
    public 
    view 
    returns (uint) {
      return asset.balanceOf(address(this));
  }
  /*//////////////////////////////////////////////////////////////
                      DEPOSIT/WITHDRAWAL LOGIC
  //////////////////////////////////////////////////////////////*/
  function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
      require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");
      asset.safeTransferFrom(msg.sender, address(this), assets);
      _mint(receiver, shares);
      emit Deposit(msg.sender, receiver, assets, shares);
  }

  function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
      assets = previewMint(shares); 
      asset.safeTransferFrom(msg.sender, address(this), assets);
      _mint(receiver, shares);
      emit Deposit(msg.sender, receiver, assets, shares);
  }

  function withdraw(
      uint256 assets,
      address receiver,
      address owner
  ) public virtual returns (uint256 shares) {
      shares = previewWithdraw(assets); 
      _burn(owner, shares);
      emit Withdraw(msg.sender, receiver, owner, assets, shares);
      asset.safeTransfer(receiver, assets);
  }

  function redeem(
      uint256 shares,
      address receiver,
      address owner
  ) public virtual returns (uint256 assets) {
      require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
      _burn(owner, shares);
      emit Withdraw(msg.sender, receiver, owner, assets, shares);
      asset.safeTransfer(receiver, assets);
  }

  /*//////////////////////////////////////////////////////////////
                          ACCOUNTING LOGIC
  //////////////////////////////////////////////////////////////*/
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
}
