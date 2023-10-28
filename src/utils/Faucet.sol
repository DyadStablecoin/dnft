// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ERC20} from "@solmate/src/tokens/ERC20.sol";

// TODO: Put in a seperate dir
contract Faucet is ERC20("Faucet Token", "FT", 18) {

  function mint(address _to, uint256 _amount) external {
    _mint(_to, _amount);
  }
}
