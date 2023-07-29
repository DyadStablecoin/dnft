// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Owned} from "@solmate/src/auth/Owned.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";

contract Dyad is ERC20, Owned {
  constructor(address owner) 
    ERC20("DYAD Stable", "DYAD", 18) 
    Owned(owner) {}

  function mint(address to,   uint amount) external onlyOwner {_mint(to,   amount);}
  function burn(address from, uint amount) external onlyOwner {_burn(from, amount);}
}
