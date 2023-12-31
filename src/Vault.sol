// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";

import {IVault} from "./interfaces/IVault.sol";
import {IAggregatorV3} from "./interfaces/IAggregatorV3.sol";
import {DNft} from "./DNft.sol";
import {Dyad} from "./Dyad.sol";
import {Staking} from "./Staking.sol";
import {VaultManager} from "./VaultManager.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC4626} from "@solmate/src/mixins/ERC4626.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "@solmate/src/utils/SafeTransferLib.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

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

      _grantRole(MINTER_ROLE,   address(_staking));
      _grantRole(MINTER_ROLE,   address(_vaultManager));
      _grantRole(TRANSFER_ROLE, address(_vaultManager));
  }

  modifier ownerOrVaultManager(uint id) {
    if (dNft.ownerOf(id) != msg.sender && address(vaultManager) != msg.sender) {
      revert NotOwner();
    }
    _;
  }

  /*//////////////////////////////////////////////////////////////
                        CUSTOM VAULT METHODS
  //////////////////////////////////////////////////////////////*/
  function mint(
      address to,
      uint    amount
  ) external {
      if (!hasRole(MINTER_ROLE, msg.sender)) revert NotMinter();
      _mint(to, amount);
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

  // copy-paste from solmate ERC20 implementation without the approval
  function transferFrom(
      address from,
      address to,
      uint256 amount
  ) public override returns (bool) {
      if (!hasRole(TRANSFER_ROLE, msg.sender)) revert NotTransferer();
      balanceOf[from] -= amount;
      unchecked { balanceOf[to] += amount; }
      emit Transfer(from, to, amount);
      return true;
  }

  /*//////////////////////////////////////////////////////////////
                        "ERC4626" FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  function deposit(
    uint id,
    uint assets
  ) 
    public 
    returns (uint) {
      if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
      return super.deposit(assets, address(uint160(id)));
  }

  function mint(
    uint id,
    uint shares
  ) 
    public 
    returns (uint) {
      if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
      return super.mint(shares, address(uint160(id)));
  }

  /// @inheritdoc IVault
  function withdraw(
    uint    id,
    uint    assets,
    address receiver
  ) 
    public 
      ownerOrVaultManager(id) 
    returns (uint) { 
      address owner = address(uint160(id));
      uint shares = previewWithdraw(assets); 
      beforeWithdraw(assets, shares);
      _burn(owner, shares);
      emit Withdraw(msg.sender, receiver, owner, assets, shares);
      asset.safeTransfer(receiver, assets);
      return shares;
  }

  /// @inheritdoc IVault
  function redeem(
    uint    id,
    uint    shares,
    address receiver
  ) 
    public 
      ownerOrVaultManager(id) 
    returns (uint) {
      address owner = address(uint160(id));
      uint assets = previewRedeem(shares);
      require(assets != 0, "ZERO_ASSETS");
      beforeWithdraw(assets, shares);
      _burn(owner, shares);
      emit Withdraw(msg.sender, receiver, owner, assets, shares);
      asset.safeTransfer(receiver, assets);
      return assets;
  }

  /*//////////////////////////////////////////////////////////////
       INHERITED ERC4626 FUNCTIONS ARE NOT DIRECTLY CALLABLE
  //////////////////////////////////////////////////////////////*/
  function deposit(
      uint    assets,
      address receiver
  ) public override pure returns (uint shares) {
      revert NotSupported();
  }

  function mint(
      uint    shares,
      address receiver
  ) public override pure returns (uint assets) {
      revert NotSupported();
  }

  function withdraw(
      uint    assets,
      address receiver,
      address owner
  ) public override pure returns (uint shares) {
      revert NotSupported();
  }

  function redeem(
      uint    shares,
      address receiver,
      address owner
  ) public override pure returns (uint assets) {
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
}
