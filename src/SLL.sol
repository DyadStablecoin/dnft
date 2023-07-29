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

  uint public constant THRESHOLD  = 66_0000000000000000; // 66%

  mapping (address => bool) public licensedVaults; // vault   => is licensed
  mapping (address => uint) public votes;          // vault   => votes
  mapping (uint    => bool) public voted;          // dNft id => voted

  constructor(
    DNft _dNft,
    Dyad _dyad
  ) { 
    dNft = _dNft;
    dyad = _dyad;
  }

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
    if (votes[vault].divWadDown(dNft.totalSupply()) > THRESHOLD) {
      licensedVaults[vault] = true;
    }
  }

  /// @inheritdoc ISLL
  function removeLicense(address vault) external {
    if (votes[vault].divWadDown(dNft.totalSupply()) <= THRESHOLD) {
      licensedVaults[vault] = false;
    }
  }

  /// @inheritdoc ISLL
  function mint(address to, uint amount) external {
    if (!licensedVaults[msg.sender]) { revert NotLicensedToMint(); }
    dyad.mint(to, amount);
  }

  /// @inheritdoc ISLL
  function burn(address from, uint amount) external {
    if (!licensedVaults[msg.sender]) { revert NotLicensedToBurn(); }
    dyad.burn(from, amount);
  }
}
