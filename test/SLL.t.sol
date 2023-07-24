// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { SLL } from "../src/SLL.sol";
import { DNft } from "../src/DNft.sol";

contract SLLTest is Test {
  DNft dNft;
  SLL  sll;

  address constant RANDOM_VAULT = address(211);

  function setUp() public {
    dNft = new DNft();
    sll  = new SLL(dNft);
  }

  function voteFor() public {
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    sll.voteFor(id, RANDOM_VAULT);
  }

  function test_hasEnoughVotes() public {
    voteFor();
    voteFor();
    voteFor();
  }

  receive() external payable {}

  function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
    return 0x150b7a02;
  }
}
