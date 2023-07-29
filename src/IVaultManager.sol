// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IVaultManager {
  error OnlyOwner();
  error TooManyVaults();
  error IndexOutOfBounds();
}
