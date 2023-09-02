// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Script.sol";

import { VaultManager } from "../src/VaultManager.sol";
import { VaultManagerSLL } from "../src/VaultManagerSLL.sol";
import { VaultSLL } from "../src/VaultSLL.sol";
import { Vault } from "../src/Vault.sol";
import { Dyad } from "../src/Dyad.sol";
import { DNft } from "../src/DNft.sol";
import { Staking } from "../src/Staking.sol";

contract DeployBase is Script {
  function deploy(
      // address       _owner,
      // address       _collat,
      // string memory _collatSymbol, 
      // address       _collatOracle
  )
    public 
    payable 
     {
      vm.startBroadcast();

      // ZoraMock     zora    = new ZoraMock();
      // DNft         dNft    = new DNft(ERC721(zora));
      // VaultFactory factory = new VaultFactory(dNft);
      // dNft.setFactory(address(factory));
      // dNft.transferOwnership(address(_owner));

      // address vault = factory.deploy(
      //   _collat,
      //   _collatSymbol, 
      //   _collatOracle 
      // );

      vm.stopBroadcast();
      // return (
        // address(dNft),
        // address(Vault(vault).dyad()),
        // address(vault),
        // address(factory), 
        // address(zora)
      // );
  }
}
