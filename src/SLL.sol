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
      address vault
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner(); 
      if (hasVoted[id][vault])            revert VotedBefore(); 
      hasVoted[id][vault] = true;
      votes[vault]       += 1;
  }

  function removeVote(
      uint    id,
      address vault
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner();
      if (!hasVoted[id][vault])           revert NotVotedBefore();
      hasVoted[id][vault] = false;
      votes[vault]       -= 1;
  }

  function license(address vault) external {
    if (votes[vault].divWadDown(dNft.totalSupply()) <= LICENSE_THRESHOLD) {
      revert NotEnoughVotes();
    }
    isLicensed[vault] = true;
  }

  function removeLicense(address vault) external {
    if (votes[vault].divWadDown(dNft.totalSupply()) > UNLICENSE_THRESHOLD) {
      revert TooManyVotes();
    }
    isLicensed[vault] = false;
  }
}
