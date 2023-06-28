// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ERC721, ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {SafeTransferLib} from "@solmate/src/utils/SafeTransferLib.sol";
import {Owned} from "@solmate/src/auth/Owned.sol";
import {IDNft} from "./IDNft.sol";

contract DNft is ERC721Enumerable, Owned, IDNft {
  using SafeTransferLib for address;

  uint public constant INSIDER_MINTS  = 800;
  uint public constant START_PRICE    = 0.1   ether;
  uint public constant PRICE_INCREASE = 0.001 ether;

  uint public insiderMints; // Number of insider mints
  uint public publicMints;  // Number of public mints

  constructor()
    ERC721("Dyad NFT", "dNFT") 
    Owned(msg.sender) 
    {}

  /// @inheritdoc IDNft
  function mintNft(address to)
    external 
    payable
    returns (uint) {
      uint price = START_PRICE + (PRICE_INCREASE * publicMints);
      if (msg.value < price) revert InsufficientFunds();
      if (msg.value > price) to.safeTransferETH(msg.value - price);
      publicMints++;
      return _mintNft(to);
  }

  /// @inheritdoc IDNft
  function mintInsiderNft(address to)
    external 
      onlyOwner 
    returns (uint) {
      if (++insiderMints > INSIDER_MINTS) revert InsiderMintsExceeded();
      return _mintNft(to); 
  }

  function _mintNft(address to)
    private 
    returns (uint) {
      uint id = totalSupply();
      _safeMint(to, id); // re-entrancy
      emit NftMinted(id, to);
      return id;
  }

  function drain(address to)
    external
      onlyOwner
  {
    uint balance = address(this).balance;
    to.safeTransferETH(balance);
    emit Drained(to, balance);
  }
}
