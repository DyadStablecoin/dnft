// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {Vault} from "./Vault.sol";
import {IStaking} from "./interfaces/IStaking.sol";

import {Owned} from "@solmate/src/auth/Owned.sol";

contract Staking is IStaking, Owned {
  DNft  public immutable dNft;
  Vault public vault;

  mapping(uint => uint) public rewards;
  mapping(uint => uint) public balanceOf;
  mapping(uint => uint) public lastUpdated;

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
      uint reward = _reward(
          balanceOf[id], 
          block.timestamp - lastUpdated[id]
      );
      rewards[id] += reward;
  }

  function _reward(
      uint amount, 
      uint duration
  ) internal
    pure
    returns (uint) {
      return amount * duration;
  }
}
