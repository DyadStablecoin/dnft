// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import { BaseTest } from "./BaseTest.sol";

contract VaultTest is BaseTest {
  function test_mint() public {
    // has to be the vault manager or the staking contract
    vm.prank(address(vault.vaultManager()));
    vault.mint(address(1), 200);
  }
}
