// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft}              from "./DNft.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";
import {Owned}             from "@solmate/src/auth/Owned.sol";

abstract contract Licenser is Owned(msg.sender) {

  mapping (address => bool) public isLicensed; 

  constructor() {}

  function add(address vault) external onlyOwner {
    isLicensed[vault] = true;
  }

  function remove(address vault) external onlyOwner {
    isLicensed[vault] = false;
  }
}
