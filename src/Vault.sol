// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {VaultPosition} from "./VaultPosition.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IAggregatorV3} from "./interfaces/IAggregatorV3.sol";

import {ERC4626} from "@solmate/src/mixins/ERC4626.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract Vault is IVault, ERC4626 {
  using FixedPointMathLib for uint;
  using SafeCast          for int;

  DNft          public immutable dNft;
  VaultPosition public immutable vaultPosition;
  IAggregatorV3 public immutable oracle;

  mapping (uint => uint) public xp; // dNftId => xp
  uint                   public totalXp;

  constructor(
      DNft          _dNft,
      VaultPosition _vaultPosition,
      IAggregatorV3 _oracle,
      ERC20         _asset,
      string memory _name,
      string memory _symbol
  ) ERC4626(_asset, _name, _symbol) {
      dNft          = _dNft;
      vaultPosition = _vaultPosition;
      oracle        = _oracle;
  }

  function deposit(
    uint    dNftId,
    uint    assets,
    address receiver, 
    uint    lockInSeconds
  ) external {
    super.deposit(assets, receiver);
    uint positionId = vaultPosition.mint(dNft.ownerOf(dNftId));
    vaultPosition.addPosition(
      dNftId, 
      positionId, 
      VaultPosition.Position({
        start:  block.timestamp,
        end:    block.timestamp + lockInSeconds,
        status: VaultPosition.Status.Open
      })
    );

    xp[dNftId] = 100;
  }

  function deposit(uint256 assets, address receiver) public override returns (uint shares) {
    revert NotImplemented();
  }

  function totalAssets() public view override returns (uint) {
    return asset.balanceOf(address(this));
  }

  // collateral price in USD
  function _collatPrice() 
    private 
    view 
    returns (uint) {
      (
        uint80 roundID,
        int256 price,
        , 
        uint256 timeStamp, 
        uint80 answeredInRound
      ) = oracle.latestRoundData();
      if (timeStamp == 0)            revert IncompleteRound();
      if (answeredInRound < roundID) revert StaleData();
      return price.toUint256();
  }
}
