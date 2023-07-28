// // SPDX-License-Identifier: MIT
// pragma solidity =0.8.17;

// import {IVaultPosition} from "./interfaces/IVaultPosition.sol";

// import {ERC721} from "@solmate/src/tokens/ERC721.sol";
// import {ERC4626} from "@solmate/src/mixins/ERC4626.sol";

// contract VaultPosition is IVaultPosition, ERC721 {
//   constructor(
//     string memory name, 
//     string memory symbol 
//   ) ERC721(name, symbol) {}

//   function addPosition(
//     uint dNftId, 
//     uint positionId,
//     Position memory position
//   ) 
//     // TODO: only owner
//     external {
//       positions[dNftId][positionId] = position;
//   }

//   function mint(address to) 
//     external 
//     // TODO: only owner
//     returns (uint id) {
//       id = totalPositions;
//       _mint(to, id);
//       totalPositions++;
//       return id;
//   }

//   function burn(uint id) 
//     external 
//     // TODO: only owner
//     returns (uint) {
//       id = totalPositions;
//       _burn(id);
//       totalPositions--;
//       return id;
//   }

//   function tokenURI(uint tokenId) 
//     public 
//     pure 
//     override 
//     returns (string memory) {
//       return string(abi.encodePacked(tokenId));
//   }
// }
