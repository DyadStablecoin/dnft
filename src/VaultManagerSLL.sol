// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {SLL} from "./SLL.sol";

// SLL := Social Licensing Layer for Vault Managers
contract VaultManagerSLL is SLL {
  constructor(DNft _dNft) SLL(_dNft, 66e16, 50e16) {}
}
