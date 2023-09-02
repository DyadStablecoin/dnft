// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Script.sol";

import {DeployBase} from "./DeployBase.s.sol";
import {Parameters} from "../src/Parameters.sol";
import { DNft } from "../src/DNft.sol";
import {IAggregatorV3} from "../src/interfaces/IAggregatorV3.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";

contract DeployGoerli is Script, Parameters {
  function run() public {
      new DeployBase().deploy(
        DNft(GOERLI_DNFT),
        IAggregatorV3(GOERLI_ORACLE), 
        ERC20(GOERLI_WETH)
      );
  }
}
