// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ISLL} from "./ISLL.sol";
import {DNft} from "./DNft.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

// SLL := Social Licensing Layer
contract SLL is ISLL {
  using FixedPointMathLib for uint; 

  DNft public immutable dNft;

  uint public constant THRESHOLD  = 200000000000000000; // 20%
  uint public constant MAX_VAULTS = 5;

  address[] public licensedVaults; // Length is always < MAX_VAULTS

  mapping (address => uint256) public votes; // vault   => votes
  mapping (uint    => bool)    public voted; // DNft id => voted

  constructor(DNft _dNft) { dNft = _dNft; }

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

  function hasEnoughVotes(address vault) public view returns (bool) {
    if (countVotes(vault) > THRESHOLD) { return true; }
    return false;
  }

  function add(address vault) external returns (bool) {
    if (!hasEnoughVotes(vault)) return false;
    if (licensedVaults.length < MAX_VAULTS) {
      licensedVaults.push(vault); 
      return true;
    }

    uint indexOfLeastVotes = 0;
    uint leastVotes        = type(uint256).max;

    for (uint i = 0; i < MAX_VAULTS; i++) {
      if (countVotes(licensedVaults[i]) < leastVotes) {
        indexOfLeastVotes = i;
      }
    }

    if (countVotes(vault) > leastVotes) {
      licensedVaults[indexOfLeastVotes] = vault;
      return true;
    }

    return false;
  }
}
