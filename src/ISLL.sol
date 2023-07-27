// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface ISLL {
  error OnlyOwner();
  error VotedBefore();
  error NotVotedBefore();

  /**
   * @notice Vote for a vault to be licensed.
   * @param id The id of the DNft to vote for.
   * @param vault The vault to vote for.
   */
  function vote(uint id, address vault) external;

  /**
   * @notice Remove a vote for a vault to be licensed.
   * @param id The id of the DNft to vote for.
   * @param vault The vault to vote for.
   */
  function removeVote(uint id, address vault) external;

  /**
   * @notice License a vault.
   * @param vault The vault to license.
   */
  function license(address vault) external;
}
