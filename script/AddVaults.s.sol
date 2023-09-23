// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import { DNft } from "../src/DNft.sol";
import { VaultManager } from "../src/VaultManager.sol";
import { VaultManagerSLL } from "../src/VaultManagerSLL.sol";
import { VaultSLL } from "../src/VaultSLL.sol";
import { Addresses } from "./Addresses.Goerli.sol";

import "forge-std/Script.sol";

contract AddVaults is Script, Addresses {
  DNft dNft                       = DNft(dNft_addr);
  VaultManagerSLL vaultManagerSLL = VaultManagerSLL(vaultManagerSLL_addr);
  VaultSLL vaultSLL               = VaultSLL(vaultSLL_addr);
  address dyad                    = dyad_addr;
  VaultManager vaultManager       = VaultManager(vaultManager_addr);
  address staking                 = staking_addr;
  address vault                   = vault_addr;

  function run() public {
    vm.startBroadcast();

    address pubKey = vm.envAddress("PUBLIC_KEY");

    uint id1 = dNft.mintNft{value: 0.102 ether}(pubKey);
    uint id2 = dNft.mintNft{value: 0.102 ether}(pubKey);

    address vaultManagerAddress = address(vaultManager);

    vaultManagerSLL.vote(id1, vaultManagerAddress);
    vaultManagerSLL.vote(id2, vaultManagerAddress);
    vaultManagerSLL.license(vaultManagerAddress);

    vaultSLL.vote(id1, vault);
    vaultSLL.vote(id2, vault);
    vaultSLL.license(vault);

    vm.stopBroadcast();
  }

  receive() external payable {}

  function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
    return 0x150b7a02;
  }
}
