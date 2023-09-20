// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import { DNft } from "../src/DNft.sol";
import { VaultManager } from "../src/VaultManager.sol";
import { VaultManagerSLL } from "../src/VaultManagerSLL.sol";

import "forge-std/Script.sol";

contract AddVaults is Script {
  // on goerli
  DNft dNft            = DNft(0x7B9B6CAAd6eE04E9173b49f33aB8a01E096cF258);
  VaultManagerSLL vaultManagerSLL = VaultManagerSLL(0x0686d75307040EE0C86790D0a62b6c95e3E857C9);
  address VaultSLL        = 0x25B716D9dCc09842413161abF0F3ff336d165a87;
  address Dyad            = 0xf47D4F3F3Cd98d34e559eFe71B5aCcAb97E4560D;
  VaultManager vaultManager = VaultManager(0x1C0c439abd9958b55eBF7Fa8030b5fc725ca21cb);
  address Staking         = 0x9D5Fd41ee4A4A09c3135936C7B1595D6b3A779d3;
  address Vault           = 0xFaB3989658312862408eECCB6D815B95dC161ED0;

  function run() public {
    // console.log(address(this).balance);
    console.log(3333);
    dNft.mintNft{value: 0.102 ether}(0xCdff3Ca9272928106f00940A2623f1Ea117e9117);

    // vaultManagerSLL.addVault(VaultSLL);
      
  }
}
