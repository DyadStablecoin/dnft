// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IVault {
  error StaleData      ();
  error IncompleteRound();

  event Deposit(
    address indexed caller,
    address indexed owner,
    uint256 assets,
    uint256 shares
  );

  event Withdraw(
    address indexed caller,
    address indexed receiver,
    address indexed owner,
    uint256 assets,
    uint256 shares
  );
}
