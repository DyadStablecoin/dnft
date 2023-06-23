// SPDX-License-Identifier: MIT
pragma solidity = 0.8.17;

interface IDNft {
  event NftMinted(uint indexed id, address indexed to);
  event Drained  (address indexed to, uint amount);

  error InsiderMintsExceeded ();
  error InsufficientFunds    ();

  /**
   * @dev Mints an dNFT and transfers it to the given `to` address.
   * 
   * Requirements:
   * - msg.value exceeds the minting price
   *
   * Emits a {NFTMinted} event on successful execution.
   *
   * @param to The address to which the minted NFT will be transferred.
   * @return id The ID of the minted NFT.
   *
   * Throws a {InsufficientFunds} error if the sender does not provide enough ETH to mint the NFT.
   */
  function mintNft(address to) external payable returns (uint id);

  /**
   * @notice Mint new insider DNft to `to` 
   * @dev Note:
   *      - An insider dNFT does not require buring ETH to mint
   * @dev Will revert:
   *      - If not called by contract owner
   *      - If the maximum number of insider mints has been reached
   *      - If `to` is the zero address
   * @dev Emits:
   *      - MintNft(address indexed to, uint indexed id)
   * @param to The address to mint the dNFT to
   * @return id Id of the new dNFT
   */
  function mintInsiderNft(address to) external returns (uint id);
}
