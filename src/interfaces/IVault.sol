// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ERC20} from "@solmate/src/tokens/ERC20.sol";

interface IVault {
  error NotOwner       ();
  error NotSupported   ();
  error NotTransferable();
  error StaleData      ();
  error IncompleteRound();

  // function asset() external view returns (ERC20);
  function collatPrice() external view returns (uint);
}
