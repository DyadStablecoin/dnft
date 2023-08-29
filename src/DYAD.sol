// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Owned} from "@solmate/src/auth/Owned.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";

contract Dyad is ERC20("DYAD Stable", "DYAD", 18), Owned {
  mapping (address => mapping (uint => uint)) public mintedDyad; // dNft id => minted dyad

  constructor(address owner) Owned(owner) {}

  function mint(
      address manager,
      uint    id,
      address to,
      uint    amount
  ) external onlyOwner {
      _mint(to, amount);
      mintedDyad[manager][id] += amount;
  }

  function burn(
      address manager,
      uint    id,
      address from,
      uint    amount
  ) external onlyOwner {
      _burn(from, amount);
      mintedDyad[manager][id] -= amount;
  }

  // vault manager to mint
  // vault to use as collateral for vault manager
  // we have 2 SLL
}
