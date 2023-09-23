// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

contract Parameters {

  // ---------------- DNft ----------------
  uint START_PRICE    = 0 ether;
  uint PRICE_INCREASE = 0 ether;

  // ---------------- Goerli ----------------
  address GOERLI_DNFT = 0x8f49F321CB37A2313b7880A8A6495A8741Fdd23A;
  address GOERLI_ORACLE = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;
  address GOERLI_WETH   = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
  string  GOERLI_WETH_SYMBOL = "WETH";

  // ---------------- Mainnet ----------------
  address MAINNET_DNFT = 0xDc400bBe0B8B79C07A962EA99a642F5819e3b712;
  address MAINNET_ORACLE = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
  address MAINNET_WETH   = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  string  MAINNET_WETH_SYMBOL = "WETH";
}
