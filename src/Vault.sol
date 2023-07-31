// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "./DNft.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IAggregatorV3} from "./interfaces/IAggregatorV3.sol";

import {ERC20} from "@solmate/src/tokens/ERC20.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract Vault is IVault, ERC20 {
  using FixedPointMathLib for uint;
  using SafeCast          for int;

  ERC20         public immutable asset;
  DNft          public immutable dNft;
  IAggregatorV3 public immutable oracle;

  mapping (uint => uint) public xp; // dNftId => xp
  uint                   public totalXP;

  uint public totalPositions;

  constructor(
      DNft          _dNft,
      IAggregatorV3 _oracle,
      ERC20         _asset,
      string memory _name,
      string memory _symbol
  ) ERC20(_name, _symbol, _asset.decimals()) {
      asset  = _asset;
      dNft   = _dNft;
      oracle = _oracle;
  }

  function deposit(
    uint    dNftId,
    uint    assets,
    address receiver, 
    uint    lockInSeconds
  ) external {
    uint lockSizeUSD = assets.mulWadDown(_collatPrice());
    uint startingXP  = xp[dNftId];
    uint xpGained    = lockSizeUSD.mulWadDown(lockInSeconds);
    xpGained         = xpGained.mulWadDown(uint(1).divWadDown(uint(1) + startingXP.divWadDown(totalXP)));
    xp[dNftId]       = xpGained;
    totalXP         += xpGained;
  }

  function withdraw() public {}
  function mint() public {}
  function liquidate() public {}
  function redeem() public {}

  function totalAssets() public view returns (uint) {
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
