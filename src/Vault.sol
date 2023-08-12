// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {Dyad} from "./DYAD.sol";
import {Staking} from "./Staking.sol";
import {VaultManager} from "./VaultManager.sol";
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
  using SafeCast          for int;
  using SafeTransferLib   for ERC20;
  using FixedPointMathLib for uint;

  uint public constant MIN_COLLATERIZATION_RATIO = 15e17; // 150%

  DNft          public immutable dNft;
  Dyad          public immutable dyad;
  VaultManager  public immutable vaultManager;
  IAggregatorV3 public immutable oracle;

  constructor(
      DNft          _dNft,
      Dyad          _dyad,
      VaultManager  _vaultManager,
      IAggregatorV3 _oracle,
      Staking       _staking, 
      ERC20         _asset,
      string memory _name,
      string memory _symbol
  ) ERC4626(_asset, _name, _symbol)
    Owned(address(_staking))
  {
      dNft         = _dNft;
      dyad         = _dyad;
      vaultManager = _vaultManager;
      oracle       = _oracle;
  }

  /*//////////////////////////////////////////////////////////////
                        CUSTOM VAULT METHODS
  //////////////////////////////////////////////////////////////*/
  function liquidate(
      uint id,
      uint receiver
  ) external {
      if (vaultManager.collatRatio(id) < MIN_COLLATERIZATION_RATIO) {
        _transfer(
          id,
          receiver,
          balanceOf[address(uint160(id))]
        );
      }
  }

  function mint(
    address to,
    uint    amount
  ) external
    onlyOwner {
      super._mint(to, amount);
  }

  // collateral price in USD
  function collatPrice() 
    public 
    view 
    override
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

  /*//////////////////////////////////////////////////////////////
                          DYAD FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  function mintDyad(
      uint    id, 
      uint    amount, 
      address to
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
      // if (_collatRatio(from) < MIN_COLLATERIZATION_RATIO) revert CrTooLow(); 
      dyad.mint(to, amount);
  }

  function redeemDyad(
      uint id, 
      uint amount 
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
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
    uint    amount
  ) 
    public 
    override 
    returns (bool) {
      revert NotTransferable();
  }

  function transfer(
    address to,
    uint    amount
  ) 
    public 
    override 
    returns (bool) {
      revert NotTransferable();
  }

  function _transfer(
    uint from,
    uint to,
    uint amount
  ) 
    internal 
    returns (bool) {
      super.transferFrom(
        address(uint160(from)),
        address(uint160(to)),
        amount
      );
  }

  function transferFrom(
    address from,
    address to,
    uint    amount
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
}
