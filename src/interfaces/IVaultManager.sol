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
  error VaultAlreadyAdded();

  event Added  (uint indexed id, address indexed vault);
  event Removed(uint indexed id, address indexed vault);
  event Liquidation(uint indexed from, uint indexed to);

  /*
   * @notice Add a new vault to a specific dNFT by its ID.
   * @dev Only the owner of the dNFT with the given ID can add vaults.
   * @param id The unique identifier of the dNFT.
   * @param vault The address of the vault to be added.
   * Emits an `Added` event upon successful addition.
   * Reverts if:
   *   - The caller is not the owner of the dNFT.
   *   - The maximum number of allowed vaults per dNFT has been reached.
   *   - The provided vault address is not licensed by the SLL.
   *   - The provided vault address has already been added to the dNFT.
   */
  function add(uint id, address vault) external;

  /*
   * @notice Remove a vault address from a specific dNFT by its ID and index.
   * @dev Only the owner of the dNFT with the given ID can remove vaults.
   * @dev Can change the order of the vaults!
   * @param id The unique identifier of the dNFT.
   * @param index The index of the vault to be removed within the dNFT's vault list.
   * Emits a `Removed` event upon successful removal.
   * Reverts if:
   *   - The caller is not the owner of the dNFT.
   *   - The provided index is out of bounds.
   *   - The vault at the specified index is not associated with the dNFT.
   */
  function remove(uint id, uint index) external;

  /**
   * @notice Calculate the collateralization ratio of a dNFT given by its ID.
   * @dev The collat ratio is the ratio of the total USD value of associated
   *      vaults to the minted dyad tokens.
   * @param id The unique identifier of the dNFT for which to calculate the 
   *        collateralization ratio.
   * @return The collateralization ratio as a unsigned integer. If the dNFT
   *         has not minted any dyad tokens, it returns the maximum possible
   *         unsigned integer value. Otherwise, it returns the collat ratio
   *         rounded down.
   */
  function collatRatio(uint id) external returns (uint);

  /**
   * @notice Calculate the total USD value of all vaults associated with a
   *         dNFT given by its ID.
   * @dev The function iterates through all vaults associated with the dNFT, 
   *      calculates the USD value of each vault, and aggregates them to obtain
   *      the total USD value.
   * @param id The unique identifier of the dNFT 
   * @return The total USD value of all vaults associated with the dNFT,
   *         represented as an unsigned integer.
   */
  function getVaultsUsdValue(uint id) external returns (uint);
}
