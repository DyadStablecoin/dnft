// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IVaultManager} from "./IVaultManager.sol";
import {DNft} from "./DNft.sol";
import {SLL} from "./SLL.sol";

contract VaultManager is IVaultManager {
  DNft public immutable dNft;
  SLL  public immutable sll;

  uint public constant MAX_VAULTS = 5;

  mapping (uint => address[])                 public vaults; 
  mapping (uint => mapping (address => uint)) public vaultsIndex;
  mapping (uint => mapping (address => bool)) public isDNftVault;

  constructor(DNft _dNft, SLL _sll) {
    dNft = _dNft;
    sll = _sll;
  }

  function add(uint id, address vault) external {
    if (dNft.ownerOf(id)  != msg.sender) revert OnlyOwner(); 
    if (vaults[id].length  > MAX_VAULTS) revert TooManyVaults();
    if (!sll.isLicensed(vault))          revert VaultNotLicensed();
    vaults[id].push(vault);
    isDNftVault[id][vault] = true;
    vaultsIndex[id][vault] = vaults[id].length - 1;
    emit Added(id, vault);
  }

  function remove(uint id, address vault) external {
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
}
