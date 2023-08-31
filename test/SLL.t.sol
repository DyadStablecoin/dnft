// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { SLL } from "../src/SLL.sol";
import { ISLL } from "../src/interfaces/ISLL.sol";
import { VaultManagerSLL } from "../src/VaultManagerSLL.sol";
import { DNft } from "../src/DNft.sol";
import { Dyad } from "../src/Dyad.sol";

contract SLLTest is Test {
 DNft dNft;
 Dyad dyad;
 VaultManagerSLL sll;

 address constant RANDOM_VAULT = address(211);

 function setUp() public {
   dNft = new DNft();
   sll  = new VaultManagerSLL(dNft);
   dyad = new Dyad(sll);
 }

 function vote() public returns (uint) {
   uint id = dNft.mintNft{value: 1 ether}(address(this));
   sll.vote(id, RANDOM_VAULT);
   return id;
 }

 ///////////////////////////
 // vote
 function test_vote() public {
   uint id = vote();
   assertEq(sll.hasVoted(id, RANDOM_VAULT), true);
   assertEq(sll.votes(RANDOM_VAULT), 1);
 }

 function testRevert_vote_onlyOwner() public {
   uint id = vote();
   vm.prank(address(0));
   vm.expectRevert(ISLL.OnlyOwner.selector);
   sll.vote(id, RANDOM_VAULT);
 }

 function testRevert_vote_votedBefore() public {
   uint id = vote();
   vm.expectRevert(ISLL.VotedBefore.selector);
   sll.vote(id, RANDOM_VAULT);
 }

 ///////////////////////////
 // removeVote
 function test_removeVote() public {
   uint id = vote();
   sll.removeVote(id, RANDOM_VAULT);
   assertEq(sll.hasVoted(id, RANDOM_VAULT), false);
   assertEq(sll.votes(RANDOM_VAULT), 0);
 }

 function testRevert_removeVote_onlyOwner() public {
   uint id = vote();
   vm.prank(address(0));
   vm.expectRevert(ISLL.OnlyOwner.selector);
   sll.removeVote(id, RANDOM_VAULT);
 }

 function testRevert_removeVote_notVotedBefore() public {
   uint id = dNft.mintNft{value: 1 ether}(address(this));
   vm.expectRevert(ISLL.NotVotedBefore.selector);
   sll.removeVote(id, RANDOM_VAULT);
 }

 ///////////////////////////
 // license
 function test_license() public {
   for (uint i = 0; i < 12; i++) {
     vote();
   }
   for (uint i = 0; i < 3; i++) {
     dNft.mintNft{value: 1 ether}(address(this));
   }
   assertFalse(sll.isLicensed(RANDOM_VAULT));
   sll.license(RANDOM_VAULT);
   assertTrue(sll.isLicensed(RANDOM_VAULT));
 }

 ///////////////////////////
 // remove license
 function test_removeLicense() public {
   uint id = vote();
   assertFalse(sll.isLicensed(RANDOM_VAULT));
   sll.license(RANDOM_VAULT);
   assertTrue(sll.isLicensed(RANDOM_VAULT));
   sll.removeVote(id, RANDOM_VAULT);
   sll.removeLicense(RANDOM_VAULT);
   assertFalse(sll.isLicensed(RANDOM_VAULT));
 }

 receive() external payable {}

 function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
   return 0x150b7a02;
 }
}
