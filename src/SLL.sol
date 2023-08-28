// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ISLL} from "./ISLL.sol";
import {DNft} from "./DNft.sol";
import {Dyad} from "./DYAD.sol";
import {VaultManager} from "./VaultManager.sol";

import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

// SLL := Social Licensing Layer
contract SLL is ISLL {
  using FixedPointMathLib for uint; 

  VaultManager public immutable vaultManager;
  DNft         public immutable dNft;
  Dyad         public immutable dyad;

  uint public constant LICENSE_THRESHOLD   = 66_0000000000000000; // 66%
  uint public constant UNLICENSE_THRESHOLD = 50_0000000000000000; // 50%

  mapping (address => uint) public votes;                           // vault   => votes
  mapping (uint    => mapping (address => bool)) public hasVoted;   // dNft id => voted
  mapping (address => bool) public isLicensed; // vault   => is licensed
  mapping (uint    => uint) public mintedDyad; // dNft id => minted dyad

  constructor(
    VaultManager _vaultManager,
    DNft         _dNft,
    Dyad         _dyad
  ) { 
    vaultManager = _vaultManager;
    dNft         = _dNft;
    dyad         = _dyad;
  }

  function vote(
      uint    id,
      address vault
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner(); 
      if (hasVoted[id][vault])            revert VotedBefore(); 
      hasVoted[id][vault]  = true;
      votes[vault] += 1;
  }

  function removeVote(
      uint    id,
      address vault
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner();
      if (!hasVoted[id][vault])           revert NotVotedBefore();
      hasVoted[id][vault]  = false;
      votes[vault] -= 1;
  }

  function license(address vault) external {
    if (votes[vault].divWadDown(dNft.totalSupply()) <= LICENSE_THRESHOLD) {
      revert NotEnoughVotes();
    }
    isLicensed[vault] = true;
  }

  function unlicense(address vault) external {
    if (votes[vault].divWadDown(dNft.totalSupply()) > UNLICENSE_THRESHOLD) {
      revert TooManyVotes();
    }
    isLicensed[vault] = false;
  }
}
