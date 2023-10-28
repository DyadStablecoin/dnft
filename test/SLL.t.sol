// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { SLL } from "../src/SLL.sol";
import { ISLL } from "../src/interfaces/ISLL.sol";
import { VaultManagerSLL } from "../src/VaultManagerSLL.sol";
import { DNft } from "../src/DNft.sol";
import { Dyad } from "../src/Dyad.sol";
import { BaseTest } from "./BaseTest.sol";

contract SLLTest is BaseTest {
 address constant RANDOM_VAULT = address(211);
 
 function vote() public returns (uint) {
   uint id = dNft.mintNft{value: 1 ether}(address(this));
   vaultSLL.vote(id, RANDOM_VAULT);
   return id;
 }

 ///////////////////////////
 // vote
 function test_vote() public {
   uint id = vote();
   assertEq(vaultSLL.hasVoted(id, RANDOM_VAULT), true);
   assertEq(vaultSLL.votes(RANDOM_VAULT), 1);
 }

 function testRevert_vote_onlyOwner() public {
   uint id = vote();
   vm.prank(address(0));
   vm.expectRevert(ISLL.OnlyOwner.selector);
   vaultSLL.vote(id, RANDOM_VAULT);
 }

 function testRevert_vote_votedBefore() public {
   uint id = vote();
   vm.expectRevert(ISLL.VotedBefore.selector);
   vaultSLL.vote(id, RANDOM_VAULT);
 }

 ///////////////////////////
 // removeVote
 function test_removeVote() public {
   uint id = vote();
   vaultSLL.removeVote(id, RANDOM_VAULT);
   assertEq(vaultSLL.hasVoted(id, RANDOM_VAULT), false);
   assertEq(vaultSLL.votes(RANDOM_VAULT), 0);
 }

 function testRevert_removeVote_onlyOwner() public {
   uint id = vote();
   vm.prank(address(0));
   vm.expectRevert(ISLL.OnlyOwner.selector);
   vaultSLL.removeVote(id, RANDOM_VAULT);
 }

 function testRevert_removeVote_notVotedBefore() public {
   uint id = dNft.mintNft{value: 1 ether}(address(this));
   vm.expectRevert(ISLL.NotVotedBefore.selector);
   vaultSLL.removeVote(id, RANDOM_VAULT);
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
   assertFalse(vaultSLL.isLicensed(RANDOM_VAULT));
   vaultSLL.license(RANDOM_VAULT);
   assertTrue(vaultSLL.isLicensed(RANDOM_VAULT));
 }

 ///////////////////////////
 // remove license
 function test_removeLicense() public {
   vote();
   uint id = vote();
   assertFalse(vaultSLL.isLicensed(RANDOM_VAULT));
   vaultSLL.license(RANDOM_VAULT);
   assertTrue(vaultSLL.isLicensed(RANDOM_VAULT));
   vaultSLL.removeVote(id, RANDOM_VAULT);
   vaultSLL.removeLicense(RANDOM_VAULT);
   assertFalse(vaultSLL.isLicensed(RANDOM_VAULT));
 }
}
