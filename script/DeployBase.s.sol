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
import {Parameters} from "../src/Parameters.sol";
import {IAggregatorV3} from "../src/interfaces/IAggregatorV3.sol";

import {ERC20} from "@solmate/src/tokens/ERC20.sol";

contract DeployBase is Script {
  function deploy(
      DNft          _dNft, 
      IAggregatorV3 _oracle,
      ERC20         _collateral
  )
    public 
    payable 
     {
      vm.startBroadcast();

      VaultManagerSLL vaultManagerSLL = new VaultManagerSLL(_dNft);
      VaultSLL        vaultSLL        = new VaultSLL(_dNft);
      Dyad            dyad            = new Dyad(vaultManagerSLL);
      VaultManager    vaultManager    = new VaultManager(_dNft, vaultSLL, dyad);
      Staking         staking         = new Staking(_dNft);
      Vault           vault           = new Vault(
                                        _dNft,
                                        vaultManager,
                                        _oracle,
                                        staking, 
                                        _collateral, 
                                        "Wrapped Ether",
                                        "WETH"
                                      );


      vm.stopBroadcast();
  }
}
