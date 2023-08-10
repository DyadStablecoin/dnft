// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ISLL} from "./ISLL.sol";
import {DNft} from "./DNft.sol";
import {Dyad} from "./Dyad.sol";

import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

// SLL := Social Licensing Layer
contract SLL is ISLL {
  using FixedPointMathLib for uint; 

  DNft public immutable dNft;
  Dyad public immutable dyad;

  uint public constant   LICENSE_THRESHOLD = 66_0000000000000000; // 66%
  uint public constant UNLICENSE_THRESHOLD = 50_0000000000000000; // 50%

  mapping (address => uint) public votes;      // vault   => votes
  mapping (uint    => bool) public hasVoted;   // dNft id => voted
  mapping (address => bool) public isLicensed; // vault   => is licensed
  mapping (address => uint) public mintedDyad;

  constructor(
    DNft _dNft,
    Dyad _dyad
  ) { 
    dNft = _dNft;
    dyad = _dyad;
  }

  /// @inheritdoc ISLL
  function vote(
      uint    id,
      address vault
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner(); 
      if (hasVoted[id])                   revert VotedBefore(); 
      hasVoted[id]  = true;
      votes[vault] += 1;
  }

  /// @inheritdoc ISLL
  function removeVote(
      uint    id,
      address vault
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner();
      if (!hasVoted[id])                  revert NotVotedBefore();
      hasVoted[id]  = false;
      votes[vault] -= 1;
  }

  /// @inheritdoc ISLL
  function license(address vault) external {
    if (votes[vault].divWadDown(dNft.totalSupply()) <= LICENSE_THRESHOLD) {
      revert NotEnoughVotes();
    }
    isLicensed[vault] = true;
  }

  /// @inheritdoc ISLL
  function unlicense(address vault) external {
    if (votes[vault].divWadDown(dNft.totalSupply()) > UNLICENSE_THRESHOLD) {
      revert TooManyVotes();
    }
    isLicensed[vault] = false;
  }

  /// @inheritdoc ISLL
  function mint(address to, uint amount) external {
    if (!isLicensed[msg.sender]) revert NotLicensedToMint();
    dyad.mint(to, amount);
    mintedDyad[to] += amount;
  }

  /// @inheritdoc ISLL
  function burn(address from, uint amount) external {
    if (!isLicensed[msg.sender]) revert NotLicensedToBurn();
    dyad.burn(from, amount);
    mintedDyad[from] -= amount;
  }
}
