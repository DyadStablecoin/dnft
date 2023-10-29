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

  /**
   * @notice Allows the owner or vault manager to withdraw assets for a specific 
   *         dNft and transfer them to a designated receiver.
   * @dev Very similar to the ERC4626 withdraw function with the exception that
   *      the access control allows the dNft holder and vault manager to withdraw
   * @param id The unique identifier of the dNFT.
   * @param assets The amount of assets to be withdrawn.
   * @param receiver The address to which the assets will be transferred.
   * @return The amount of shares burnt during the withdrawal process.
   */
  function withdraw(
    uint    id,
    uint    assets,
    address receiver
  ) external returns (uint);

  /**
   * @notice Allows the owner or vault manager to redeem shares for a specific 
   *         dNft and transfer them to a designated receiver.
   * @dev Very similar to the ERC4626 withdraw function with the exception that
   *      the access control allows the dNft holder and vault manager to withdraw
   * @param id The unique identifier of the dNFT.
   * @param shares The shares to be redeemed
   * @param receiver The address to which the assets will be transferred.
   * @return The amount of assets transferred during the redemption process.
   */
  function redeem(
    uint    id,
    uint    shares,
    address receiver
  ) external returns (uint);
}
