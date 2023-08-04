// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {Vault} from "./Vault.sol";
import {IStaking} from "./interfaces/IStaking.sol";

import {Owned} from "@solmate/src/auth/Owned.sol";

contract Staking is IStaking, Owned {
  DNft  public immutable dNft;
  Vault public vault;

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
      // TODO
  }

  function unstake(
      uint id, 
      uint amount
  ) external {
      // TODO
  }
}
