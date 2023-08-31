// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { VaultManager } from "../src/VaultManager.sol";
import { VaultManagerSLL } from "../src/VaultManagerSLL.sol";
import { VaultSLL } from "../src/VaultSLL.sol";
import { Dyad } from "../src/DYAD.sol";
import { DNft } from "../src/DNft.sol";

contract VaultManagerTest is Test {
  DNft            dNft;
  Dyad            dyad;
  VaultManager    vaultManager;
  VaultManagerSLL vaultManagerSLL;
  VaultSLL        vaultSLL;
  
  address constant RANDOM_VAULT = address(42);
  
  function setUp() public {
    dNft = new DNft();
    vaultSLL = new VaultSLL(dNft);
    vaultManagerSLL  = new VaultManagerSLL(dNft);
    dyad = new Dyad(vaultManagerSLL);
    vaultManager = new VaultManager(dNft, vaultSLL, dyad);
  }
  
  ///////////////////////////
  // add
  function test_add() public {
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    vaultSLL.vote(id, RANDOM_VAULT);
    vaultSLL.license(RANDOM_VAULT);
    vaultManager.add(id, RANDOM_VAULT);
  }

  receive() external payable {}
  
  function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
    return 0x150b7a02;
  }
}
