// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IVaultManager} from "./interfaces/IVaultManager.sol";
import {DNft} from "./DNft.sol";
import {VaultSLL} from "./VaultSLL.sol";
import {Dyad} from "./Dyad.sol";

import {ERC20} from "@solmate/src/tokens/ERC20.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

// TODO: refactor
interface IVault {
  function collatPrice() external view returns (uint);
  function decimals()    external view returns (uint);
  function balanceOf(address account) external view returns (uint);
  function mint(address to, uint amount) external;
  function withdraw(uint id, uint assets, address receiver) external returns (uint);
  function transferFrom(address from, address to, uint amount) external returns (bool);
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

  // NOTE: Changes the order of vaults!
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
      uint _dyad = dyad.mintedDyad(address(this), id); // save gas
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
          // use shares to calculate usd value
          uint shares = vault.balanceOf(address(uint160(id)));
          usdValue = vault.convertToAssets(shares) * vault.collatPrice();
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
      dyad.mint(from, to, amount);
      if (collatRatio(from) < MIN_COLLATERIZATION_RATIO) revert CrTooLow(); 
  }

  function burnDyad(
      uint    from, 
      uint    amount 
  ) external {
      if (dNft.ownerOf(from) != msg.sender) revert NotOwner();
      dyad.burn(from, msg.sender, amount);
      if (collatRatio(from) < MIN_COLLATERIZATION_RATIO) revert CrTooLow(); 
  }

  function redeemDyad(
      address vault,
      uint    from, 
      address to, 
      uint    amount
  ) external {
      if (dNft.ownerOf(from) != msg.sender) revert NotOwner();
      IVault _vault = IVault(vault);
      dyad.burn(from, msg.sender, amount);
      uint collat = amount * (10**_vault.decimals()) / _vault.collatPrice();
      _vault.withdraw(from, collat, to);
  }

  function liquidate(
      uint from, 
      uint to 
  ) external {
      if (collatRatio(from) >= MIN_COLLATERIZATION_RATIO) revert CR_NotLowEnough();
      uint mintedDyad = dyad.mintedDyad(address(this), from);
      dyad.burn(from, msg.sender, mintedDyad);

      // TODO: refactor so we don't re-calculate getVaultsUsdValue
      uint totalUsdValue = getVaultsUsdValue(from);

      uint sharesBonus   = mintedDyad.divWadDown(totalUsdValue) - 66e16;
      uint numberOfVaults = vaults[from].length;
      for (uint i = 0; i < numberOfVaults; i++) {
        IVault vault = IVault(vaults[from][i]);
        uint shares = vault.balanceOf(address(uint160(from)));
        vault.transferFrom(
          address(uint160(from)),
          address(uint160(to)),
          shares
        );
        vault.mint(address(uint160(from)), shares.mulWadDown(1e18 + sharesBonus));
      }
      emit Liquidation(from, to);
  }

  /*//////////////////////////////////////////////////////////////
                        HELPERS
  //////////////////////////////////////////////////////////////*/
  function getVaultsCount(uint id) external view returns (uint) {
    return vaults[id].length;
  }
}
