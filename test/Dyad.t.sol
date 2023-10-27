// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Test.sol";

import { BaseTest } from "./BaseTest.sol";

contract DyadTest is BaseTest {

  uint amount = 420;

  function test_mint() public {
    uint id = dNft.mintNft{value: 0.1 ether}(address(this));

    vm.prank(address(vaultManager));
    dyad.mint(id, address(this), amount);
  }

  function testFail_vaultManagerNotLicensedForMint() public {
    uint id = dNft.mintNft{value: 0.1 ether}(address(this));

    dyad.mint(id, address(this), amount);
    assertEq(dyad.mintedDyad(address(vaultManager), id), amount);
  }

  function test_burn() public {
    uint id = dNft.mintNft{value: 0.1 ether}(address(this));

    // mint
    vm.prank(address(vaultManager));
    dyad.mint(id, address(this), amount);

    // burn
    vm.prank(address(vaultManager));
    dyad.burn(id, address(this), amount);

    assertEq(dyad.mintedDyad(address(vaultManager), id), 0);
  }

  function testFail_vaultManagerNotLicensedForBurn() public {
    uint id = dNft.mintNft{value: 0.1 ether}(address(this));
    dyad.burn(id, address(this), amount);
  }
}
