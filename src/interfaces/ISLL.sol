// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

// SLL := Social Licensing Layer
interface ISLL {
  error OnlyOwner();
  error VotedBefore();
  error NotVotedBefore();
  error NotEnoughVotes();
  error TooManyVotes();

  event Voted(uint indexed id, address indexed vault);
  event RemovedVote(uint indexed id, address indexed vault);
  event Licensed(address indexed vault);
  event RemovedLicense(address indexed vault);

  /**
   * @notice Allows the dNft owner to vote for a vault to be
   * @dev Allows a dNft owner to cast a vote for a particular vault. 
   *      The owner can only vote once for a given vault. Emits an
   *      event to indicate the vote's success.
   * @param id The unique ID of the dNft.
   * @param vault The vault to vote for.
   */
  function vote(uint id, address vault) external;

  /**
   * @notice Allows the dNft owner to remove a vote for a vault
   * @dev Allows a dNft owner to remove his vote for a particular vault. 
   *      The owner can only remove his vote if he has voted for that
   *      vault before. Emits an event to indicate the vote's success.
   * @param id The unique ID of the dNft.
   * @param vault The vault to remove the vote for.
   */
  function removeVote(uint id, address vault) external;

  /**
   * @notice Grants a license to a vault if it has received sufficient votes.
   * @dev Allows a vault to be granted a license if it has
   * received a number of votes that exceeds the defined threshold. A 
   * vault's eligibility for a license is determined based on the ratio
   * of its votes to the total supply of NFTs. If the vault has not received
   * enough votes, the function reverts with a 'NotEnoughVotes' error.  
   * @param vault The address of the vault to be licensed.
   */
  function license(address vault) external;

  /**
   * @notice Revokes a previously granted license from a vault if it
   *         did not receive enough votes.
   * @dev Allows the revocation of a license from a vault if
   *      it has lost an excessive number of votes, surpassing the
   *      defined threshold. The decision to revoke a license is based on
   *      the ratio of the vault's votes to the total supply of NFTs. If
   *      the vault has not enough votes, it reverts with a
   *      'TooManyVotes' error. 
   * @param vault The address of the vault to have its license revoked.
   */
  function removeLicense(address vault) external;
}
