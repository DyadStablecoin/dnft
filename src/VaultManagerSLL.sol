// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ISLL} from "./interfaces/ISLL.sol";
import {DNft} from "./DNft.sol";
import {Dyad} from "./DYAD.sol";
import {VaultManager} from "./VaultManager.sol";
import {SLL} from "./SLL.sol";

import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

// SLL := Social Licensing Layer for Vault Managers
contract VaultManagerSLL is SLL {
  constructor(DNft _dNft) SLL(_dNft, 66e16, 50e16) {}
}
