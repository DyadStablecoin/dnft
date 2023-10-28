// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ISLL} from "./interfaces/ISLL.sol";
import {DNft} from "./DNft.sol";

import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

// SLL := Social Licensing Layer
abstract contract SLL is ISLL {
  using FixedPointMathLib for uint;

  DNft public immutable dNft;

  uint public immutable LICENSE_THRESHOLD; 
  uint public immutable UNLICENSE_THRESHOLD; 

  // vault => votes
  mapping (address => uint)                      public votes; 
  // dNft id => (vault => hasVoted)
  mapping (uint    => mapping (address => bool)) public hasVoted; 
  // vault => is licensed
  mapping (address => bool)                      public isLicensed; 

  modifier onlyOwner(uint id) {
    if (dNft.ownerOf(id) != msg.sender) revert OnlyOwner();
    _;
  }

  constructor(
    DNft _dNft, 
    uint licenseThreshold,
    uint unlicenseThreshold
  ) { 
    dNft = _dNft;
    LICENSE_THRESHOLD   = licenseThreshold;
    UNLICENSE_THRESHOLD = unlicenseThreshold;
  }

  /// @inheritdoc ISLL
  function vote(
      uint    id,
      address vault
  ) external 
      onlyOwner(id) 
    {
      if (hasVoted[id][vault]) revert VotedBefore(); 
      hasVoted[id][vault] = true;
      votes[vault]       += 1;
      emit Voted(id, vault);
  }

  /// @inheritdoc ISLL
  function removeVote(
      uint    id,
      address vault
  ) external 
      onlyOwner(id) 
    {
      if (!hasVoted[id][vault]) revert NotVotedBefore();
      hasVoted[id][vault] = false;
      votes[vault]       -= 1;
      emit RemovedVote(id, vault);
  }

  /// @inheritdoc ISLL
  function license(address vault) external {
    if (votes[vault].divWadDown(dNft.totalSupply()) <= LICENSE_THRESHOLD) {
      revert NotEnoughVotes();
    }
    isLicensed[vault] = true;
    emit Licensed(vault);
  }

  /// @inheritdoc ISLL
  function removeLicense(address vault) external {
    if (votes[vault].divWadDown(dNft.totalSupply()) > UNLICENSE_THRESHOLD) {
      revert TooManyVotes();
    }
    isLicensed[vault] = false;
    emit RemovedLicense(vault);
  }
}
