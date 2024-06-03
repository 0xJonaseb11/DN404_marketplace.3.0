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
    string private _baseURI;
    bytes32 private allowlistRoot;
    
    uint120 public publicPrice;
    uint120 public allowlistPrice;
    bool public live;
    uint256 public numMinted;
    uint256 public MAX_SUPPLY;

    // Error handling
    error InvalidProof();
    error InvalidPrice();
    error ExceedsMaxMint();
    error TotalSupplyReached();
    error NotLive();

    // checks
    modifier isValidMint(uint256 price, uint256 amount) {
        if (!live) {
            revert NotLive();
        }
        if (price * amount != msg.value) {
            revert InvalidPrice();
        }
        if (numMinted + amount > MAX_SUPPLY) {
            revert TotalSupplyReached();
        }
        _;
    }

    // contract init with constructor
    constructor (
        string memory name_,
        string memory symbol_,
        uint256 _MAX_SUPPLY,
        uint120 publicPrice_,
        uint96 initialTokenSupply,
        address initialSupplyOwner
    ) ERC20Permit("NFTMintDN404") {
        _initializeOwner(msg.sender);

        _name = name_;
        _symbol = symbol_;
        MAX_SUPPLY = _MAX_SUPPLY;
        publiPrice = publicPrice_;

        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(initialTokenSupply, initialSupplyOwner, mirror);
    }

    // initialize minting functionality
    function mint(uint256 amount) isValidMint(publicPrice, amount) {
        // uncheck overflows
        unchecked {
            ++numMinted;
        }
        _mint(msg.sender, amount);
    }

    // initialize the allowlistMint functionality
    function allowlistMint(uint256 amount, bytes32[] calldata proof) public payable 
    isValidMint(allowlistPrice, amount) {
        if (
            !MerkleProofLib.verifyCallData(
                proof, allowlistRoot, keccak256(abi.encodePacked(msg.sender))
            )
           ) {
                revert InvalidProof();
            }
            unchecked {
                ++numMinted;
            }
            _mint(msg.sender, amount);
    }

    // initialize token SetBaseurl()
    function setBaseUrl(string baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    // inititialize  set prices functinality
    function setPrices(uint120 publicPrice_, uint120 allowlistPrice_) public onlyOwner {
        publicPrice = publicPrice_;
        allowlistPrice = allowlistPrice_;
    }

    // initialize the toggle live functionality
    function toggleLive() public onlyOwner {
        if (live) {
            live = false;
        } else {
            live = true;
        }
    }

    // initialize withdraw functionality
    function withdraw() {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }

    // retrieving the basic information
    function name() public view override returns(string memory) {
        return _name;
    }

    function symbol() public view returns(string memory) {
        return _symbol;
    }

    // initialize tokenURI functionality - token metadata
    function tokenURI(uint256 tokenId) public view override returns(string memory result) {
        if (bytes(_baseURI).length != 0) {
            result = string(abi.encodePacked(_baseURI, LibString.toString(tokenId)));
        } /*else {
            revert();
        } */
    }

    // initialize allowlist mamagement functionality
    function setAllowlist(bytes32 allowlistRoot_) public onlyOwner {
        allowlistRoot = allowlistRoot_;
    }

    // initialize utility functions
    function nftTotalSupply() public view returns(uint256) {
        return _totalNFTSupply;
    }

    function nftBalanceOf(address owner) public view returns(uint256) {
        return _balanceOfNFT(owner);
    }

    function previewNextTokenId() public view returns(uint256) {
        return _nextTokenId;
    }

    function getURI() public view returns(string memory) {
        return _baseURI;
    }
}