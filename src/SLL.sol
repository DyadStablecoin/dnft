// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ISLL} from "./interfaces/ISLL.sol";
import {DNft} from "./DNft.sol";
import {Dyad} from "./DYAD.sol";
import {VaultManager} from "./VaultManager.sol";

import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

// SLL := Social Licensing Layer for Vault Managers
contract SLL is ISLL {
  using FixedPointMathLib for uint; 

  DNft public immutable dNft;

  uint public constant LICENSE_THRESHOLD   = 66_0000000000000000; // 66%
  uint public constant UNLICENSE_THRESHOLD = 50_0000000000000000; // 50%

  mapping (address => uint) public votes;                           // vault   => votes
  mapping (uint    => mapping (address => bool)) public hasVoted;   // dNft id => voted
  mapping (address => bool) public isLicensed; // vault => is licensed

  constructor(DNft _dNft) { dNft = _dNft; }

  function vote(
      uint    id,
      address vaultManager
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner(); 
      if (hasVoted[id][vaultManager])     revert VotedBefore(); 
      hasVoted[id][vaultManager] = true;
      votes[vaultManager]       += 1;
  }

  function removeVote(
      uint    id,
      address vaultManager
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner();
      if (!hasVoted[id][vaultManager])    revert NotVotedBefore();
      hasVoted[id][vaultManager] = false;
      votes[vaultManager]       -= 1;
  }

  function license(address vaultManager) external {
    if (votes[vaultManager].divWadDown(dNft.totalSupply()) <= LICENSE_THRESHOLD) {
      revert NotEnoughVotes();
    }
    isLicensed[vaultManager] = true;
  }

  function unlicense(address vaultManager) external {
    if (votes[vaultManager].divWadDown(dNft.totalSupply()) > UNLICENSE_THRESHOLD) {
      revert TooManyVotes();
    }
    isLicensed[vaultManager] = false;
  }
}
