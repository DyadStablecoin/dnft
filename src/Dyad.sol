// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IDyad} from "./interfaces/IDyad.sol";
import {DNft}  from "./DNft.sol";
import {SLL}   from "./SLL.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";

contract Dyad is ERC20("DYAD Stable", "DYAD", 18), IDyad {
  DNft public immutable dNft;
  SLL  public immutable sll;  // Vault Manager SLL

  // vault manager => (dNFT ID => dyad)
  mapping (address => mapping (uint => uint)) public mintedDyad; 

  constructor(
    DNft _dNft,
    SLL  _sll
  ) { 
    dNft = _dNft;
    sll  = _sll; 
  }

  modifier exists(uint id) {
    if (dNft.ownerOf(id) == address(0)) revert DNftDoesNotExist(); 
    _; 
  }

  modifier licensed() {
    if (!sll.isLicensed(msg.sender)) revert NotLicensed();
    _;
  }

  /// @inheritdoc IDyad
  function mint(
      uint    id, 
      address to,
      uint    amount
  ) external 
      exists(id) 
      licensed 
    {
      mintedDyad[msg.sender][id] += amount;
      _mint(to, amount);
  }

  /// @inheritdoc IDyad
  function burn(
      uint    id, 
      address from,
      uint    amount
  ) external 
      exists(id) 
      licensed 
    {
      mintedDyad[msg.sender][id] -= amount;
      _burn(from, amount);
  }
}
