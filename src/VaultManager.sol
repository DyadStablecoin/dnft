// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IVaultManager} from "./IVaultManager.sol";
import {DNft} from "./DNft.sol";
import {SLL} from "./SLL.sol";
import {Dyad} from "./DYAD.sol";

import {ERC20} from "@solmate/src/tokens/ERC20.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

interface IVault {
  function asset()       external view returns (ERC20);
  function collatPrice() external view returns (uint);
  function decimals()    external view returns (uint);
}

contract VaultManager is IVaultManager {
  using FixedPointMathLib for uint;

  DNft public immutable dNft;
  SLL  public immutable sll;
  Dyad public immutable dyad;

  uint public constant MAX_VAULTS = 5;
  uint public constant MIN_COLLATERIZATION_RATIO = 15e17; // 150%

  mapping (uint => address[])                 public vaults; 
  mapping (uint => mapping (address => uint)) public vaultsIndex;
  mapping (uint => mapping (address => bool)) public isDNftVault;

  constructor(
    DNft _dNft,
    SLL  _sll,
    Dyad _dyad
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
      vaults[id].push(vault);
      isDNftVault[id][vault] = true;
      vaultsIndex[id][vault] = vaults[id].length - 1;
      emit Added(id, vault);
  }

  function remove(
      uint    id,
      address vault
  ) external {
      if (dNft.ownerOf(id)  != msg.sender) revert OnlyOwner();
      if (!isDNftVault[id][vault])         revert NotDNftVault();
      uint index        = vaultsIndex[id][vault];
      uint vaultsLength = vaults[id].length;
      address oldVault  = vaults[id][index];
      for (uint i = index; i < vaultsLength - 1; ) {
        vaults[i] = vaults[i+1];
        unchecked { i++; }
      }
      vaults[id].pop();
      isDNftVault[id][oldVault] = false;
      vaultsIndex[id][oldVault] = 0; 
      emit Removed(id, oldVault);
  }

  function collatRatio(
      uint id
  ) public 
    view 
    returns (uint) {
      uint totalUsdValue;
      uint numberOfVaults = vaults[id].length;
      for (uint i = 0; i < numberOfVaults; i++) {
        IVault vault    = IVault(vaults[id][i]);
        uint   usdVaule = vault.asset().balanceOf(address(uint160(id))) * vault.collatPrice();
        totalUsdValue += usdVaule / (10**vault.decimals());
      }
      uint _dyad = sll.mintedDyad(address(uint160(id))); // save gas
      if (_dyad == 0) return type(uint).max;
      return totalUsdValue.divWadDown(_dyad);
  }

  function liquidate(
      uint from, 
      uint to 
  ) external {
      if (collatRatio(from) < MIN_COLLATERIZATION_RATIO) revert CR_NotLowEnough();
      uint mintedDyad = sll.mintedDyad(address(uint160(from)));
      sll.burn(msg.sender, mintedDyad);
      sll.setMintedDyad(address(uint160(from)), 0);
      
      uint sharesBonus = 0;
      // TODO: loop over all vaults to get their shares
  }
}
