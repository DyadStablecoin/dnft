// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IDyad} from "./interfaces/IDyad.sol";
import {SLL} from "./SLL.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";

contract Dyad is ERC20("DYAD Stable", "DYAD", 18), IDyad {
  SLL public immutable sll;

  error NotLicensed();

  // vault manager => (dNft id => minted dyad)
  mapping (address => mapping (uint => uint)) public mintedDyad; 

  constructor(SLL _sll) { sll = _sll; }

  modifier onlyLicensed() {
    if (!sll.isLicensed(msg.sender)) revert NotLicensed();
    _;
  }

  /// @inheritdoc IDyad
  function mint(
      uint    id, // we trust the caller to use an id that exists
      address to,
      uint    amount
  ) external onlyLicensed {
      mintedDyad[msg.sender][id] += amount;
      _mint(to, amount);
  }

  /// @inheritdoc IDyad
  function burn(
      uint    id, // we trust the caller to use an id that exists
      address from,
      uint    amount
  ) external onlyLicensed {
      mintedDyad[msg.sender][id] -= amount;
      _burn(from, amount);
  }
}
