// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import { DNft } from "../src/DNft.sol";

contract DNftsTest is Test {
  DNft dNft;

  function setUp() public {
    dNft = new DNft();
  }

  // -------------------- mintNft --------------------
  function test_mintNft() public {
    dNft.mintNft{value: 0.1 ether}(address(this));
  }
  function test_mintNft_multiple() public {
    dNft.mintNft{value: 0.1 ether}(address(this));
    dNft.mintNft{value: 0.101 ether}(address(this));
    dNft.mintNft{value: 0.102 ether}(address(this));
  }
  function testCannot_mintNft_insufficientFunds() public {
    vm.expectRevert();
    dNft.mintNft{value: 0.09 ether}(address(this));
  }


  function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
    return 0x150b7a02;
  }
}
