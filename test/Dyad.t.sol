// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Test.sol";

import { BaseTest } from "./BaseTest.sol";

contract DyadTest is BaseTest {

  function test_mint() public {
    uint id = dNft.mintNft{value: 0.1 ether}(address(this));

    vm.prank(address(vaultManager));
    dyad.mint(id, address(this), 420);
  }

  function test_burn() public {
    uint id = dNft.mintNft{value: 0.1 ether}(address(this));

    // mint
    vm.prank(address(vaultManager));
    dyad.mint(id, address(this), 420);

    // burn
    vm.prank(address(vaultManager));
    dyad.burn(id, address(this), 420);
  }
}
