// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {Staking} from "./Staking.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IAggregatorV3} from "./interfaces/IAggregatorV3.sol";

import {ERC4626} from "@solmate/src/mixins/ERC4626.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";
import {Owned} from "@solmate/src/auth/Owned.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "@solmate/src/utils/SafeTransferLib.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {SafeTransferLib} from "@solmate/src/utils/SafeTransferLib.sol";

contract Vault is IVault, Owned, ERC4626 {
  using SafeCast        for int;
  using SafeTransferLib for ERC20;

  DNft          public immutable dNft;
  IAggregatorV3 public immutable oracle;

  constructor(
      DNft          _dNft,
      Staking       _staking, 
      IAggregatorV3 _oracle,
      ERC20         _asset,
      string memory _name,
      string memory _symbol
  ) ERC4626(_asset, _name, _symbol)
    Owned(address(_staking))
  {
      dNft   = _dNft;
      oracle = _oracle;
  }

  /*//////////////////////////////////////////////////////////////
                        "ERC4626" FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  function deposit(
    uint id, 
    uint assets
  ) 
    public 
    returns (uint shares) {
      if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
      require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");
      asset.safeTransferFrom(msg.sender, address(this), assets);
      address receiver = address(uint160(id));
      _mint(receiver, shares);
      emit Deposit(msg.sender, receiver, assets, shares);
  }

  function mint(
    uint id, 
    uint shares
  ) 
    public 
    returns (uint assets) {
      if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
      assets = previewMint(shares); 
      asset.safeTransferFrom(msg.sender, address(this), assets);
      address receiver = address(uint160(id));
      _mint(receiver, shares);
      emit Deposit(msg.sender, receiver, assets, shares);
      return assets;
  }

  function withdraw(
    uint    id, 
    uint    assets,
    address receiver
  ) 
    public 
    virtual 
    returns (uint shares) {
      if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
      shares = previewWithdraw(assets); 
      beforeWithdraw(assets, shares);
      address owner = address(uint160(id));
      _burn(owner, shares);
      emit Withdraw(msg.sender, receiver, owner, assets, shares);
      asset.safeTransfer(receiver, assets);
  }

  function redeem(
    uint    id, 
    uint    shares,
    address receiver
  ) 
    public 
    virtual 
    returns (uint assets) {
      if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
      require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
      beforeWithdraw(assets, shares);
      address owner = address(uint160(id));
      _burn(owner, shares);
      emit Withdraw(msg.sender, receiver, owner, assets, shares);
      asset.safeTransfer(receiver, assets);
  }

  /*//////////////////////////////////////////////////////////////
                  ERC4626 IS NOT DIRECTLY CALLABLE
  //////////////////////////////////////////////////////////////*/
  function deposit(
    uint    assets,
    address receiver
  ) 
    public 
    override 
    returns (uint shares) {
      revert NotSupported();
  }

  /*//////////////////////////////////////////////////////////////
                      ERC20 IS NOT TRANSFERABLE
  //////////////////////////////////////////////////////////////*/
  function approve(
    address spender,
    uint amount
  ) 
    public 
    override 
    returns (bool) {
      revert NotTransferable();
  }

  function transfer(
    address to,
    uint amount
  ) 
    public 
    override 
    returns (bool) {
      revert NotTransferable();
  }

  function transferFrom(
    address from,
    address to,
    uint amount
  ) 
    public 
    override 
    returns (bool) {
      revert NotTransferable();
  }

  function permit(
    address owner,
    address spender,
    uint value,
    uint deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) 
    public 
    override {
      revert NotTransferable();
  }

  function totalAssets() 
    public 
    view 
    override 
    returns (uint) {
      return asset.balanceOf(address(this));
  }

  function mint(
    address to,
    uint    amount
  )
    external
    onlyOwner {
      super._mint(to, amount);
  }

  // collateral price in USD
  function _collatPrice() 
    private 
    view 
    returns (uint) {
      (
        uint80 roundID,
        int price,
        , 
        uint timeStamp, 
        uint80 answeredInRound
      ) = oracle.latestRoundData();
      if (timeStamp == 0)            revert IncompleteRound();
      if (answeredInRound < roundID) revert StaleData();
      return price.toUint256();
  }
}
