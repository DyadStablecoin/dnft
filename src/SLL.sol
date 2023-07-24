// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";

import {ISLL} from "./ISLL.sol";
import {DNft} from "./DNft.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

contract SLL is ISLL {
  using FixedPointMathLib for uint; 
  uint public constant THRESHOLD = 500000000000000000; // 50%

  DNft public immutable dNft;

  mapping (address => uint256) public votes; // vault   => votes
  mapping (uint    => bool)    public voted; // DNft id => voted

  constructor(DNft _dNft) {
    dNft = _dNft;
  }

  function voteFor(uint id, address vault) external {
    if (dNft.ownerOf(id) != msg.sender) { revert OnlyOwner(); }
    if (voted[id])                      { revert AlreadyVotedFor(); }
    voted[id]     = true;
    votes[vault] += 1;
  }

  function voteAgainst(uint id, address vault) external {
    if (dNft.ownerOf(id) != msg.sender) { revert OnlyOwner(); }
    if (!voted[id])                     { revert AlreadyVotedAgainst(); }
    voted[id]     = false;
    votes[vault] -= 1;
  }

  function countVotes(address vault) public view returns (uint) {
    return votes[vault].divWadDown(dNft.totalSupply());
  }

  function hasEnoughVotes(address vault) external view returns (bool) {
    if (countVotes(vault) > THRESHOLD) { return true; }
    return false;
  }
}
