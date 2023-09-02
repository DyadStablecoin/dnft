// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {SLL} from "./SLL.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";

contract Dyad is ERC20("DYAD Stable", "DYAD", 18) {
  SLL public immutable sll;

  error NotLicensed();

  // manager => (dNft id => minted dyad)
  mapping (address => mapping (uint => uint)) public mintedDyad; 

  constructor(SLL _sll) { sll = _sll; }

  function mint(
      uint    id, // we trust the caller to use an id that exists
      address to,
      uint    amount
  ) external {
      if (!sll.isLicensed(msg.sender)) revert NotLicensed();
      mintedDyad[msg.sender][id] += amount;
      _mint(to, amount);
  }

  function burn(
      uint    id, // we trust the caller to use an id that exists
      address from,
      uint    amount
  ) external {
      if (!sll.isLicensed(msg.sender)) revert NotLicensed();
      mintedDyad[msg.sender][id] -= amount;
      _burn(from, amount);
  }
}