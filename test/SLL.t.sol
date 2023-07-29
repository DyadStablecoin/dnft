// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { SLL } from "../src/SLL.sol";
import { DNft } from "../src/DNft.sol";
import { Dyad } from "../src/Dyad.sol";

contract SLLTest is Test {
  DNft dNft;
  Dyad dyad;
  SLL  sll;

  address constant RANDOM_VAULT = address(211);

  function setUp() public {
    dNft = new DNft();
    dyad = new Dyad(address(this));
    sll  = new SLL(dNft, dyad);
    dyad.transferOwnership(address(sll));
  }

  function vote() public returns (uint) {
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    sll.vote(id, RANDOM_VAULT);
    return id;
  }

  function test_vote() public {
    uint id = vote();
    assertEq(sll.votes(RANDOM_VAULT), 1);
    assertEq(sll.voted(id), true);
  }

  receive() external payable {}

  function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
    return 0x150b7a02;
  }
}
