// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IVaultPosition} from "./interfaces/IVaultPosition.sol";

import {ERC721} from "@solmate/src/tokens/ERC721.sol";
import {ERC4626} from "@solmate/src/mixins/ERC4626.sol";

contract Vault is IVaultPosition, ERC721 {
  struct Position {
    uint start;
    uint end;
  }

  // dNft id => (position id => position)
  mapping (uint => mapping (uint => Position)) public positions; 

  constructor(
    string memory name, 
    string memory symbol 
  ) ERC721(name, symbol) {}

  function tokenURI(uint256 tokenId) 
    public 
    pure 
    override 
    returns (string memory) {
      return string(abi.encodePacked(tokenId));
  }
}
