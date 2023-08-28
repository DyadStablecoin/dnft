// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IVault {
  error NotOwner       ();
  error NotSupported   ();
  error NotTransferable();
  error StaleData      ();
  error IncompleteRound();
  error CrTooLow       ();
  error NotMinter      ();
  error NotTransferer  ();
}
