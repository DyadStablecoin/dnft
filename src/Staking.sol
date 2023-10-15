// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {Vault} from "./Vault.sol";
import {IStaking} from "./interfaces/IStaking.sol";

import {Owned} from "@solmate/src/auth/Owned.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

contract Staking is IStaking, Owned {
  using FixedPointMathLib for uint;

  uint constant public RATE_INCREASE = 1e16;   // 0.01% 

  uint constant public REWARD_RATE = 8e15;   // 0.8% 
  uint constant public TIME_BONUS  = 135e12; // 0.135%

  DNft  public immutable dNft;

  Vault public vault;

  mapping(uint => uint) public rewards;
  mapping(uint => uint) public balanceOf;
  mapping(uint => uint) public lastUpdated; // block number

  constructor(DNft _dNft) Owned(msg.sender) {
    dNft = _dNft;
  }

  function setVault(
    address vault
  ) external
    onlyOwner {
      vault = vault;
  }

  function stake(
      uint id, 
      uint amount
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
      _updateReward(id);
      vault.transferFrom(msg.sender, address(this), amount);
      balanceOf[id] += amount;
  }

  function unstake(
      uint id, 
      uint amount
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
      _updateReward(id);
      balanceOf[id] -= amount;
      vault.transfer(msg.sender, amount);
  }

  function getReward(
      uint id
  ) external {
      if (dNft.ownerOf(id) != msg.sender) revert NotOwner();
      rewards[id] = 0;
      vault.mint(msg.sender, rewards[id]);
  }

  function _updateReward(
      uint id
  ) internal {
      uint lastUpdate = lastUpdated[id] == 0 ? block.number : lastUpdated[id];

      uint reward = _calcReward(
        id, 
        lastUpdate
      );
      rewards[id] += reward;

      lastUpdated[id] = block.number;
  }

  function _calcReward(
      uint id,
      uint time
  ) internal
    view
    returns (uint) {
      uint shares     = vault.balanceOf(address(uint160(id)));
      uint rewardRate = time;
      uint urp        = shares.mulWadDown(rewardRate).mulWadDown(REWARD_RATE);
      uint decay      = urp.mulWadDown(REWARD_RATE.mulWadDown(urp.divWadDown(shares)));
      return urp - decay;
  }
}
