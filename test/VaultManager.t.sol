// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { VaultManager } from "../src/VaultManager.sol";
import { VaultManagerSLL } from "../src/VaultManagerSLL.sol";
import { VaultSLL } from "../src/VaultSLL.sol";
import { Dyad } from "../src/Dyad.sol";
import { DNft } from "../src/DNft.sol";

contract VaultManagerTest is Test {
  DNft            dNft;
  Dyad            dyad;
  VaultManager    vaultManager;
  VaultManagerSLL vaultManagerSLL;
  VaultSLL        vaultSLL;
  
  address constant RANDOM_VAULT_1 = address(42);
  address constant RANDOM_VAULT_2 = address(314159);
  address constant RANDOM_VAULT_3 = address(69);
  
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
    vaultSLL.vote(id, RANDOM_VAULT_1);
    vaultSLL.license(RANDOM_VAULT_1);
    vaultManager.add(id, RANDOM_VAULT_1);
    assertEq(vaultManager.isDNftVault(id, RANDOM_VAULT_1), true);
    assertEq(vaultManager.vaults(id, 0), RANDOM_VAULT_1);
    assertEq(vaultManager.getVaultsCount(id), 1);
    vm.expectRevert();
    assertEq(vaultManager.vaults(id, 1), address(0)); // out of bounds
  }

  function test_addTwoVaults() public {
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    vaultSLL.vote(id, RANDOM_VAULT_1);
    vaultSLL.vote(id, RANDOM_VAULT_2);
    vaultSLL.license(RANDOM_VAULT_1);
    vaultSLL.license(RANDOM_VAULT_2);
    vaultManager.add(id, RANDOM_VAULT_1);
    vaultManager.add(id, RANDOM_VAULT_2);
    assertEq(vaultManager.isDNftVault(id, RANDOM_VAULT_1), true);
    assertEq(vaultManager.isDNftVault(id, RANDOM_VAULT_2), true);
    assertEq(vaultManager.vaults(id, 0), RANDOM_VAULT_1);
    assertEq(vaultManager.vaults(id, 1), RANDOM_VAULT_2);
    assertEq(vaultManager.getVaultsCount(id), 2);
    vm.expectRevert();
    vaultManager.vaults(id, 2); // out of bounds
  }

  ///////////////////////////
  // remove
  function test_remove() public {
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    vaultSLL.vote(id, RANDOM_VAULT_1);
    vaultSLL.license(RANDOM_VAULT_1);
    vaultManager.add(id, RANDOM_VAULT_1);
    vaultManager.remove(id, 0);
    assertEq(vaultManager.isDNftVault(id, RANDOM_VAULT_1), false);
    assertEq(vaultManager.getVaultsCount(id), 0);
    vm.expectRevert();
    vaultManager.vaults(id, 0);
  }

  function test_removeThreeVaults() public {
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    vaultSLL.vote(id, RANDOM_VAULT_1);
    vaultSLL.vote(id, RANDOM_VAULT_2);
    vaultSLL.vote(id, RANDOM_VAULT_3);
    vaultSLL.license(RANDOM_VAULT_1);
    vaultSLL.license(RANDOM_VAULT_2);
    vaultSLL.license(RANDOM_VAULT_3);
    vaultManager.add(id, RANDOM_VAULT_1);
    vaultManager.add(id, RANDOM_VAULT_2);
    vaultManager.add(id, RANDOM_VAULT_3);
    vaultManager.remove(id, 0);
    assertEq(vaultManager.getVaultsCount(id), 2);
    vaultManager.remove(id, 0);
    assertEq(vaultManager.getVaultsCount(id), 1);
    vaultManager.remove(id, 0);
    assertEq(vaultManager.getVaultsCount(id), 0);
  }

  ///////////////////////////
  // collatRatio
  function test_collatRatio() public {

  }

  ///////////////////////////
  // misc
  receive() external payable {}
  
  function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
    return 0x150b7a02;
  }
}
