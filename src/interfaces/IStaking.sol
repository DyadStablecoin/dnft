// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IStaking {
  error StaleData      ();
  error IncompleteRound();
  error NotTransferable();
}

