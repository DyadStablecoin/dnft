// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { VaultManager } from "../src/VaultManager.sol";
import { VaultManagerSLL } from "../src/VaultManagerSLL.sol";
import { VaultSLL } from "../src/VaultSLL.sol";
import { Vault } from "../src/Vault.sol";
import { Dyad } from "../src/Dyad.sol";
import { DNft } from "../src/DNft.sol";
import { Staking } from "../src/Staking.sol";

import { OracleMock } from "./utils/OracleMock.sol";
import { ERC20Mock } from "./utils/ERC20Mock.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";

contract VaultManagerTest is Test {
  DNft            dNft;
  Dyad            dyad;
  VaultManager    vaultManager;
  VaultManagerSLL vaultManagerSLL;
  VaultSLL        vaultSLL;
  Staking         staking;

  OracleMock      oracle;
  ERC20Mock       token;
  
  address constant RANDOM_VAULT_1 = address(42);
  address constant RANDOM_VAULT_2 = address(314159);
  address constant RANDOM_VAULT_3 = address(69);

  Vault vault;
  
  function setUp() public {
    dNft = new DNft();
    vaultSLL = new VaultSLL(dNft);
    vaultManagerSLL  = new VaultManagerSLL(dNft);
    dyad = new Dyad(vaultManagerSLL);
    oracle = new OracleMock();
    token = new ERC20Mock();
    vaultManager = new VaultManager(dNft, vaultSLL, dyad);
    staking = new Staking(dNft);
    vault = new Vault(
      dNft,
      vaultManager,
      oracle,
      staking, 
      ERC20(address(token)), 
      token.name(),
      token.symbol()
    );
  }

  function addVault(uint id, address vault) public {
    vaultSLL.vote(id, vault);
    vaultSLL.license(vault);
    vaultManager.add(id, vault);
  }
  
  ///////////////////////////
  // add
  function test_add() public {
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    addVault(id, RANDOM_VAULT_1);
    assertEq(vaultManager.isDNftVault(id, RANDOM_VAULT_1), true);
    assertEq(vaultManager.vaults(id, 0), RANDOM_VAULT_1);
    assertEq(vaultManager.getVaultsCount(id), 1);
    vm.expectRevert();
    assertEq(vaultManager.vaults(id, 1), address(0)); // out of bounds
  }

  function test_addTwoVaults() public {
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    addVault(id, RANDOM_VAULT_1);
    addVault(id, RANDOM_VAULT_2);
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
    addVault(id, RANDOM_VAULT_1);
    vaultManager.remove(id, 0);
    assertEq(vaultManager.isDNftVault(id, RANDOM_VAULT_1), false);
    assertEq(vaultManager.getVaultsCount(id), 0);
    vm.expectRevert();
    vaultManager.vaults(id, 0);
  }

  function test_removeThreeVaults() public {
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    addVault(id, RANDOM_VAULT_1);
    addVault(id, RANDOM_VAULT_2);
    addVault(id, RANDOM_VAULT_3);
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
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    addVault(id, address(vault));
    token.mint(address(this), 10e32);
    token.approve(address(vault), 10e32);
    vault.deposit(id, 10e18);
    vaultManagerSLL.vote(id, address(vaultManager));
    vaultManagerSLL.license(address(vaultManager));
    vaultManager.mintDyad(id, address(this), 1e10);
    assertTrue(vaultManager.collatRatio(id) != type(uint).max);
  }

  ///////////////////////////
  // mintDyad
  function test_mintDyad() public {
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    addVault(id, address(vault));
    token.mint(address(this), 10e32);
    token.approve(address(vault), 10e32);
    vault.deposit(id, 10e18);
    vaultManagerSLL.vote(id, address(vaultManager));
    vaultManagerSLL.license(address(vaultManager));
    vaultManager.mintDyad(id, address(this), 1e10);
    assertEq(dyad.balanceOf(address(this)), 1e10);
    assertEq(dyad.mintedDyad(address(vaultManager), id), 1e10);
  }

  ///////////////////////////
  // redeemDyad
  function test_redeemDyad() public {
    uint id = dNft.mintNft{value: 1 ether}(address(this));
    addVault(id, address(vault));
    token.mint(address(this), 10e32);
    vaultManagerSLL.vote(id, address(vaultManager));
    vaultManagerSLL.license(address(vaultManager));
    token.approve(address(vault), 10e32);
    vault.deposit(id, 10e18);
    uint oldBalance = vault.balanceOf(address(uint160(id)));
    assertTrue(oldBalance != 0);
    vaultManager.mintDyad(id, address(this), 1e10);
    vaultManager.redeemDyad(address(vault), id, address(this), 60);
    uint newBalance = vault.balanceOf(address(uint160(id)));
    assertTrue(newBalance < oldBalance);
  }

  ///////////////////////////
  // misc
  receive() external payable {}
  
  function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
    return 0x150b7a02;
  }
}
