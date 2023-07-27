// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {IVault} from "./interfaces/IVault.sol";

import {ERC4626} from "@solmate/src/mixins/ERC4626.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";

contract Vault is IVault, ERC4626 {
  DNft public immutable dNft;

  mapping (uint => uint) public xp; // id => xp

  constructor(
      DNft  _dNft,
      ERC20 _asset,
      string memory _name,
      string memory _symbol
  ) ERC4626(_asset, _name, _symbol) {
      dNft = _dNft;
  }

  function totalAssets() public view override returns (uint) {
    return asset.balanceOf(address(this));
  }
}
