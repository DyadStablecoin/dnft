// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IVaultManager} from "./IVaultManager.sol";
import {DNft} from "./DNft.sol";
import {SLL} from "./SLL.sol";

contract VaultManager is IVaultManager {

  DNft public immutable dNft;
  SLL  public immutable sll;

  uint public constant MAX_VAULTS  = 5;

  mapping (uint => address[]) public vaults; // dNft => vaults

  constructor(DNft _dNft, SLL _sll) {
    dNft = _dNft;
    sll = _sll;
  }

  function add(uint id, address vault) external {
    if (dNft.ownerOf(id)  != msg.sender) { revert OnlyOwner(); }
    if (vaults[id].length >= MAX_VAULTS) { revert TooManyVaults(); }
    vaults[id].push(vault);
  }

  function replace(uint id, address vault, uint position) external {
    if (dNft.ownerOf(id)  != msg.sender) { revert OnlyOwner(); }
    if (vaults[id].length != MAX_VAULTS) { revert TooFewVaults(); }
    vaults[id][position] = vault;
  }

  function remove(uint id, uint position) external {
    if (dNft.ownerOf(id)  != msg.sender) { revert OnlyOwner(); }
    vaults[id][position] = address(0);
  }
}
