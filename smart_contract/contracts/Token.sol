// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { DN404 } from "./lib/DN404.sol";
// Import DN404Mirror contract from external sources
import { DN404Mirror } from "dn404/src/DN404Mirror.sol";
// import Ownable contract from solady library
import { Ownable } from "solady/src/auth/Ownable.sol";
// import LibString contract from solady library
import { LibString } from "solady/src/utils/LibString.sol";
// import SafeTransferLib contract from solady library
import { SafeTransferLib } from "solady/src/utils/SafeTransferLib.sol";
// Import merkleProofLib contract from solady library
import { MerkleProofLib } from "solady/src/utils/MerkleProofLib.sol";


contract NFTMintDN404 is DN404, ERC20Permit, Ownable {

    // state varibles
    string private _name;
    string private _symbol;
    string private _baseUrl;
    bytes32 private allowlistRoot;
    
    uint120 public publicPrice;
    uint120 public allowlistPrice;
    bool public live;
    uint256 public numMinted;
    uint256 public _MAX_SUPPLY;

    // Error handling
    error InvalidProof();
    error InvalidPrice();
    error ExceedsMaxMint();
    error TotalSupplyReached();
    error NotAlive();

}