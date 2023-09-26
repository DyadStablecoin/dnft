// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ERC20} from "@solmate/src/tokens/ERC20.sol";

// NOTE: Only used for testing
// TODO: Put in a seperate dir
contract Faucet is ERC20("Faucet Token", "FT", 18) {

  uint256 public constant MIN_TIME_BETWEEN_MINTS = 1 days;
  uint256 public constant MAX_MINT_AMOUNT = 100 ether;

  mapping(address => uint256) public lastMint;

  function mint(address _to, uint256 _amount) external {
    require(block.timestamp - lastMint[_to] > MIN_TIME_BETWEEN_MINTS, "Faucet: can only mint once per day");
    require(_amount <= MAX_MINT_AMOUNT, "Faucet: can only mint 100 tokens at a time");
    lastMint[_to] = block.timestamp;
    _mint(_to, _amount);
  }
}
