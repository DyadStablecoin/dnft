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
import {Parameters} from "../src/params/Parameters.sol";
import {IAggregatorV3} from "../src/interfaces/IAggregatorV3.sol";

import {ERC20} from "@solmate/src/tokens/ERC20.sol";

contract DeployBase is Script {
  function deploy(
      IAggregatorV3 _oracle,
      ERC20         _collateral,
      address       _dNft
  )
    public 
    payable 
     {
      vm.startBroadcast();

      DNft dNft;

      // we want to deploy a new dNft contract sometimes on a testnet
      if (_dNft == address(0)) {
        dNft = new DNft();
      } else {
        dNft = DNft(_dNft);
      }

      VaultManagerSLL vaultManagerSLL = new VaultManagerSLL(dNft);
      VaultSLL        vaultSLL        = new VaultSLL(dNft);
      Dyad            dyad            = new Dyad(vaultManagerSLL);
      VaultManager    vaultManager    = new VaultManager(dNft, vaultSLL, dyad);
      Staking         staking         = new Staking(dNft);
      Vault           vault           = new Vault(
                                          dNft,
                                          vaultManager,
                                          _oracle,
                                          staking, 
                                          _collateral, 
                                          "Wrapped Ether Shares",
                                          "WETH Shares"
                                        );


      vm.stopBroadcast();
  }
}
