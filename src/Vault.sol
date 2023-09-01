// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";

import {DNft} from "./DNft.sol";
import {Dyad} from "./Dyad.sol";
import {Staking} from "./Staking.sol";
import {VaultManager} from "./VaultManager.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IAggregatorV3} from "./interfaces/IAggregatorV3.sol";

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC4626} from "@solmate/src/mixins/ERC4626.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";
import {Owned} from "@solmate/src/auth/Owned.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "@solmate/src/utils/SafeTransferLib.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {SafeTransferLib} from "@solmate/src/utils/SafeTransferLib.sol";

contract Vault is IVault, AccessControl, ERC4626 {
  using SafeCast          for int;
  using SafeTransferLib   for ERC20;
  using FixedPointMathLib for uint;

  bytes32 public constant MINTER_ROLE   = keccak256("MINTER_ROLE");
  bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

  DNft          public immutable dNft;
  VaultManager  public immutable vaultManager;
  IAggregatorV3 public immutable oracle;

  constructor(
      DNft          _dNft,
      VaultManager  _vaultManager,
      IAggregatorV3 _oracle,
      Staking       _staking, 
      ERC20         _asset,
      string memory _name,
      string memory _symbol
  ) ERC4626(_asset, _name, _symbol) {
      dNft         = _dNft;
      vaultManager = _vaultManager;
      oracle       = _oracle;

      _grantRole(MINTER_ROLE, address(_staking));
      _grantRole(MINTER_ROLE, address(_vaultManager));
      _grantRole(TRANSFER_ROLE, address(_vaultManager));
  }

  /*//////////////////////////////////////////////////////////////
                        CUSTOM VAULT METHODS
  //////////////////////////////////////////////////////////////*/
  function mint(
      address to,
      uint    amount
  ) external {
      if (!hasRole(MINTER_ROLE, msg.sender)) revert NotMinter();
      super._mint(to, amount);
  }

  // collateral price in USD
  function collatPrice() 
    public 
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

  function move(
    uint from,
    uint to,
    uint amount
  ) 
    public 
    returns (bool) {
      if (!hasRole(TRANSFER_ROLE, msg.sender)) revert NotTransferer();
      return super.transferFrom(
        address(uint160(from)),
        address(uint160(to)),
        amount
      );
  }

  /*//////////////////////////////////////////////////////////////
                        "ERC4626" FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  function deposit(uint id, uint assets) public returns (uint) {
    if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
    return super.deposit(assets, address(uint160(id)));
  }

  function mint(uint id, uint shares) public returns (uint) {
    if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
    return super.deposit(shares, address(uint160(id)));
  }

  function withdraw(uint id, uint assets, address receiver) public returns (uint) { 
    if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
    return super.withdraw(assets, receiver, address(uint160(id)));
  }

  function redeem(uint id, uint shares, address receiver) public returns (uint) {
    if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
    return super.redeem(shares, receiver, address(uint160(id)));
  }

  /*//////////////////////////////////////////////////////////////
       INHERITED ERC4626 FUNCTIONS ARE NOT DIRECTLY CALLABLE
  //////////////////////////////////////////////////////////////*/
  function deposit(
      uint    assets,
      address receiver
  ) public override returns (uint shares) {
      revert NotSupported();
  }

  function mint(
      uint    shares,
      address receiver
  ) public override returns (uint assets) {
      revert NotSupported();
  }

  function withdraw(
      uint    assets,
      address receiver,
      address owner
  ) public override returns (uint shares) {
    revert NotSupported();
  }

  function redeem(
      uint    shares,
      address receiver,
      address owner
  ) public override returns (uint assets) {
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

  /*//////////////////////////////////////////////////////////////
                    OVERRIDDEN ERC4626 FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  function totalAssets() 
    public 
    view 
    override 
    returns (uint) {
      return asset.balanceOf(address(this));
  }
}
