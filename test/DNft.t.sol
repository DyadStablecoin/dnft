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
  function test_mintNft_withRefund() public {
    uint balanceBefore = address(this).balance;
    dNft.mintNft{value: 10 ether}(address(this));
    uint balanceAfter = address(this).balance;
    assertEq(balanceBefore - balanceAfter, 0.1 ether);
  }
  function testCannot_mintNft_insufficientFunds() public {
    vm.expectRevert();
    dNft.mintNft{value: 0.09 ether}(address(this));
  }

  // -------------------- mintInsiderNft --------------------
  function test_mintInsiderNft() public {
    dNft.mintInsiderNft(address(this));
  }

  // -------------------- drain --------------------
  function test_drain() public {
    dNft.mintNft{value: 0.1 ether}(address(this));
    dNft.mintNft{value: 0.101 ether}(address(this));
    dNft.mintNft{value: 0.102 ether}(address(this));
    uint balanceBefore = address(this).balance;
    dNft.drain(address(this));
    uint balanceAfter = address(this).balance;
    assertEq(balanceAfter - balanceBefore, 0.303 ether);
  }

  receive() external payable {}

  function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
    return 0x150b7a02;
  }
}
