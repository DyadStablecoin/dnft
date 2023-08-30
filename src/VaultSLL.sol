// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {SLL} from "./SLL.sol";

// SLL := Social Licensing Layer for Vaults
contract VaultSLL is SLL {
  constructor(DNft _dNft) SLL(_dNft, 60e16, 40e16) {}
}
