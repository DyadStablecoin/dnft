// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import { DNft } from "../src/DNft.sol";

contract DNftsTest {
  DNft dNft;

  function setUp() public {
    dNft = new DNft();
  }

  // -------------------- mintNft --------------------
  function test_mintNft() public {
    dNft.mintNft{value: 0.1 ether}(address(this));
  }
}
