// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ISLL} from "./ISLL.sol";
import {DNft} from "./DNft.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

// SLL := Social Licensing Layer
contract SLL is ISLL {
  using FixedPointMathLib for uint; 

  DNft public immutable dNft;

  uint public constant THRESHOLD  = 66_0000000000000000; // 66%

  mapping (address => bool) public vaults; // vault   => is licensed
  mapping (address => uint) public votes;  // vault   => votes
  mapping (uint    => bool) public voted;  // dNft id => voted

  constructor(DNft _dNft) { dNft = _dNft; }

  /// @inheritdoc ISLL
  function vote(uint id, address vault) external {
    if (dNft.ownerOf(id) != msg.sender) { revert OnlyOwner(); }
    if (voted[id])                      { revert VotedBefore(); }
    voted[id]     = true;
    votes[vault] += 1;
  }

  /// @inheritdoc ISLL
  function removeVote(uint id, address vault) external {
    if (dNft.ownerOf(id) != msg.sender) { revert OnlyOwner(); }
    if (!voted[id])                     { revert NotVotedBefore(); }
    voted[id]     = false;
    votes[vault] -= 1;
  }

  /// @inheritdoc ISLL
  function license(address vault) external {
    votes[vault].divWadDown(dNft.totalSupply()) > THRESHOLD 
      ? vaults[vault] = true 
      : vaults[vault] = false;
  }
}
