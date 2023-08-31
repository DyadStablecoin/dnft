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

 function setUp() public {
   dNft = new DNft();
   vaultSLL = new VaultSLL(dNft);
   vaultManagerSLL  = new VaultManagerSLL(dNft);
   dyad = new Dyad(vaultManagerSLL);
   vaultManager = new VaultManager(dNft, vaultSLL, dyad);
 }

}
