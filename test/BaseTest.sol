// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Test.sol";

import { VaultManager } from "../src/VaultManager.sol";
import { VaultManagerSLL } from "../src/VaultManagerSLL.sol";
import { VaultSLL } from "../src/VaultSLL.sol";
import { Vault } from "../src/Vault.sol";
import { Dyad } from "../src/Dyad.sol";
import { DNft } from "../src/DNft.sol";
import { Staking } from "../src/Staking.sol";
import { OracleMock } from "./utils/OracleMock.sol";
import { ERC20Mock } from "./utils/ERC20Mock.sol";
import { ERC20 } from "@solmate/src/tokens/ERC20.sol";

contract BaseTest is Test {
  DNft            dNft;
  Dyad            dyad;
  VaultManager    vaultManager;
  VaultManagerSLL vaultManagerSLL;
  VaultSLL        vaultSLL;
  Staking         staking;
  Vault           vault;
  OracleMock      oracle;
  ERC20Mock       token;

  function setUp() public {
    dNft = new DNft();
    vaultSLL = new VaultSLL(dNft);
    vaultManagerSLL  = new VaultManagerSLL(dNft);
    dyad = new Dyad(dNft, vaultManagerSLL);
    oracle = new OracleMock();
    token = new ERC20Mock();
    vaultManager = new VaultManager(dNft, vaultSLL, dyad);
    staking = new Staking(dNft);
    vault = new Vault(
      dNft,
      vaultManager,
      oracle,
      staking, 
      ERC20(address(token)), 
      token.name(),
      token.symbol()
    );

    uint id = dNft.mintNft{value: 1 ether}(address(this));

    // license vault manger
    vaultManagerSLL.vote(id, address(vaultManager));
    vaultManagerSLL.license(address(vaultManager));

    // license vault
    vaultSLL.vote(id, address(vault));
    vaultSLL.license(address(vault));
    vaultManager.add(id, address(vault));
  }

  receive() external payable {}

  function onERC721Received(address, address, uint256, bytes calldata) 
    external 
    pure 
    returns (bytes4) {
      return 0x150b7a02;
  }
}
