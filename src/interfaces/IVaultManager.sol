// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IVaultManager {
  error NotOwner();
  error OnlyOwner();
  error VaultNotLicensed();
  error TooManyVaults();
  error IndexOutOfBounds();
  error NotDNftVault();
  error CR_NotLowEnough();
  error CrTooLow();

  event Added  (uint indexed id, address indexed vault);
  event Removed(uint indexed id, address indexed vault);
}
