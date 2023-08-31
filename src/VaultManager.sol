// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";

import {IVaultManager} from "./interfaces/IVaultManager.sol";
import {DNft} from "./DNft.sol";
import {VaultSLL} from "./VaultSLL.sol";
import {Dyad} from "./Dyad.sol";

import {ERC20} from "@solmate/src/tokens/ERC20.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

interface IVault {
  function collatPrice() external view returns (uint);
  function decimals()    external view returns (uint);
  function balanceOf(uint id) external view returns (uint);
  function mint(address to, uint amount) external returns (bool);
  function withdraw(uint assets, address receiver, address owner) external returns (uint);
  function move(uint from, uint to, uint amount) external returns (bool);
  function convertToAssets(uint shares) external returns (uint);
}

contract VaultManager is IVaultManager {
  using FixedPointMathLib for uint;

  DNft      public immutable dNft;
  VaultSLL  public immutable sll;
  Dyad      public immutable dyad;

  uint public constant MAX_VAULTS = 5;
  uint public constant MIN_COLLATERIZATION_RATIO = 15e17; // 150%

  mapping (uint => address[])                 public vaults; 
  mapping (uint => mapping (address => bool)) public isDNftVault;

  constructor(
    DNft      _dNft,
    VaultSLL  _sll,
    Dyad      _dyad
  ) {
    dNft = _dNft;
    sll  = _sll;
    dyad = _dyad;
  }

  function add(
      uint    id,
      address vault
  ) external {
      if (dNft.ownerOf(id)  != msg.sender) revert OnlyOwner(); 
      if (vaults[id].length  > MAX_VAULTS) revert TooManyVaults();
      if (!sll.isLicensed(vault))          revert VaultNotLicensed();
      if (isDNftVault[id][vault])          revert VaultAlreadyAdded();
      vaults[id].push(vault);
      isDNftVault[id][vault] = true;
      emit Added(id, vault);
  }

  // Does not respect the order
  function remove(
      uint id,
      uint index
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner();
      address vault = vaults[id][index];
      if (!isDNftVault[id][vault])        revert NotDNftVault();
      uint vaultsLength = vaults[id].length;
      vaults[id][index] = vaults[id][vaultsLength - 1];
      vaults[id].pop();
      isDNftVault[id][vault] = false;
      emit Removed(id, vault);
  }

  function collatRatio(
      uint id
  ) public 
    returns (uint) {
      uint totalUsdValue = getVaultsUsdValue(id);
      uint _dyad = dyad.mintedDyad(msg.sender, id); // save gas
      if (_dyad == 0) return type(uint).max;
      return totalUsdValue.divWadDown(_dyad);
  }

  function getVaultsUsdValue(
      uint id
  ) public 
    returns (uint) {
      uint totalUsdValue;
      uint numberOfVaults = vaults[id].length;
      for (uint i = 0; i < numberOfVaults; i++) {
        IVault vault = IVault(vaults[id][i]);
        uint usdValue;
        if (sll.isLicensed(address(vault))) {
          uint usdValue = vault.convertToAssets(vault.balanceOf(id)) * vault.collatPrice();
        }
        totalUsdValue += usdValue / (10**vault.decimals());
      }
      return totalUsdValue;
  }

  function mintDyad(
      uint    from, 
      address to,
      uint    amount 
  ) external {
      if (dNft.ownerOf(from) != msg.sender) revert NotOwner();
      if (collatRatio(from) < MIN_COLLATERIZATION_RATIO) revert CrTooLow(); 
      dyad.mint(from, to, amount);
  }

  function redeemDyad(
      IVault  vault,
      uint    from, 
      address to, 
      uint    amount
  ) external {
      if (dNft.ownerOf(from) != msg.sender) revert NotOwner();
      dyad.burn(from, msg.sender, amount);
      uint collat = amount * (10**vault.decimals()) / vault.collatPrice();
      vault.withdraw(collat, to, address(uint160(from)));
  }

  function liquidate(
      uint from, 
      uint to 
  ) external {
      if (collatRatio(from) < MIN_COLLATERIZATION_RATIO) revert CR_NotLowEnough();
      uint mintedDyad = dyad.mintedDyad(msg.sender, from);
      dyad.burn(from, msg.sender, mintedDyad);
      uint totalUsdValue = getVaultsUsdValue(from);
      uint sharesBonus   = mintedDyad.divWadDown(totalUsdValue) - uint(2).divWadDown(3);
      uint numberOfVaults = vaults[from].length;
      for (uint i = 0; i < numberOfVaults; i++) {
        IVault vault = IVault(vaults[from][i]);
        uint shares = vault.balanceOf(from);
        vault.move(
          from,
          to,
          shares
        );
        vault.mint(address(uint160(from)), shares.mulWadDown(1 + sharesBonus));
      }
  }

  /*//////////////////////////////////////////////////////////////
                        HELPERS
  //////////////////////////////////////////////////////////////*/
  function getVaultsCount(uint id) external view returns (uint) {
    return vaults[id].length;
  }
}
