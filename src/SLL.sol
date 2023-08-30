// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ISLL} from "./interfaces/ISLL.sol";
import {DNft} from "./DNft.sol";

import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

abstract contract SLL is ISLL {
  using FixedPointMathLib for uint; 

  DNft public immutable dNft;

  uint public immutable LICENSE_THRESHOLD; 
  uint public immutable UNLICENSE_THRESHOLD; 

  mapping (address => uint) public votes;                         // vault   => votes
  mapping (uint    => mapping (address => bool)) public hasVoted; // dNft id => voted
  mapping (address => bool) public isLicensed; // vault => is licensed

  constructor(
    DNft _dNft, 
    uint licenseThreshold,
    uint unlicenseThreshold
  ) { 
    dNft = _dNft;
    LICENSE_THRESHOLD   = licenseThreshold;
    UNLICENSE_THRESHOLD = unlicenseThreshold;
  }

  function vote(
      uint    id,
      address account
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner(); 
      if (hasVoted[id][account])          revert VotedBefore(); 
      hasVoted[id][account] = true;
      votes[account]       += 1;
  }

  function removeVote(
      uint    id,
      address account
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner();
      if (!hasVoted[id][account])         revert NotVotedBefore();
      hasVoted[id][account] = false;
      votes[account]       -= 1;
  }

  function license(address account) external {
    if (votes[account].divWadDown(dNft.totalSupply()) <= LICENSE_THRESHOLD) {
      revert NotEnoughVotes();
    }
    isLicensed[account] = true;
  }

  function unlicense(address account) external {
    if (votes[account].divWadDown(dNft.totalSupply()) > UNLICENSE_THRESHOLD) {
      revert TooManyVotes();
    }
    isLicensed[account] = false;
  }
}
