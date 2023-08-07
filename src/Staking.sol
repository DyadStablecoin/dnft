// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {Vault} from "./Vault.sol";
import {IStaking} from "./interfaces/IStaking.sol";

import {Owned} from "@solmate/src/auth/Owned.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

contract Staking is IStaking, Owned {
  using FixedPointMathLib for uint;

  uint constant public REWARD_RATE = 8e15;   // 0.8% 
  uint constant public TIME_BONUS  = 135e12; // 0.135%

  uint public constant MIN_COLLATERIZATION_RATIO = 3e18; // 300%

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
      uint reward = _calcReward(
          id, 
          balanceOf[id], 
          block.timestamp - lastUpdated[id]
      );
      rewards[id] += reward;
  }

  function _calcReward(
      uint id,
      uint amount, 
      uint duration
  ) internal
    view
    returns (uint) {
      uint shares      = vault.balanceOf(address(uint160(id)));
      uint sharesTotal = vault.totalSupply();
      // =1/(1+(B5/B6))
      uint equityControl = uint(1).divWadDown(1+shares.divWadDown(sharesTotal)); 
      // B4*(B3^(1+B2))*B1*B8
      return duration.rpow(1+TIME_BONUS, amount)
        .mulWadDown(REWARD_RATE)
        .mulWadDown(equityControl);
  }
}
