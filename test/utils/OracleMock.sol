// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IAggregatorV3} from "../../src/interfaces/IAggregatorV3.sol";

contract OracleMock is IAggregatorV3{
  int public price = 1000e8; // ETH/USD

  function setPrice(int _price) external {
    price = _price;
  }

  function latestRoundData() public view returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
  ) {
      return (1, price, 1, 1, 1);  
  }

  function decimals() public pure returns (uint8) {
    return 8;
  }

  function description() public pure returns (string memory) {
    return "ETH/USD";
  }

  function version() public pure returns (uint256) {
    return 1;
  }

  function getRoundData(uint80 _roundId) public view returns (
      uint80 roundId_,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
  ) {
      return (1, price, 1, 1, 1);  
  }
}
