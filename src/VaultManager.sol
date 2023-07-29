// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IVaultManager} from "./IVaultManager.sol";
import {DNft} from "./DNft.sol";
import {SLL} from "./SLL.sol";

contract VaultManager is IVaultManager {
  DNft public immutable dNft;
  SLL  public immutable sll;

  uint public constant MAX_VAULTS  = 5;

  mapping (uint => address[])                 public vaults; 
  mapping (uint => mapping (address => bool)) public isDNftVault;

  constructor(DNft _dNft, SLL _sll) {
    dNft = _dNft;
    sll = _sll;
  }

  function add(uint id, address vault) external {
    if (dNft.ownerOf(id)  != msg.sender) { revert OnlyOwner(); }
    if (vaults[id].length  > MAX_VAULTS) { revert TooManyVaults(); }
    vaults[id].push(vault);
    isDNftVault[id][vault] = true;
  }

  function replace(uint id, address vault, uint index) external {
    if (dNft.ownerOf(id) != msg.sender) { revert OnlyOwner(); }
    address oldVault          = vaults[id][index];
    isDNftVault[id][oldVault] = false;
    isDNftVault[id][vault]    = true;
    vaults     [id][index]    = vault;
  }

  function remove(uint id, uint index) external {
    if (dNft.ownerOf(id)  != msg.sender) { revert OnlyOwner(); }
    uint vaultsLength = vaults[id].length;
    if (index >= vaultsLength)           { revert IndexOutOfBounds(); }
    address oldVault          = vaults[id][index];
    isDNftVault[id][oldVault] = false;
    for (uint i = index; i < vaultsLength - 1; ) {
      vaults[i] = vaults[i+1];
      unchecked { i++; }
    }
    vaults[id].pop();
  }
}
