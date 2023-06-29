// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Script.sol";
import "../src/DNft.sol";

contract DeployGoerli is Script {
  function run() public {
    vm.startBroadcast();
    new DNft();
    vm.stopBroadcast();
  }
}
