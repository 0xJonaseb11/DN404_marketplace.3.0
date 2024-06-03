// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IDN404 } from "./Interface/IDN404.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";


error PriceNotMet(address nftAddress, uint256 price);
error ItemNotForSale(address nftAddress);
error NotListed(address nftAddres);
error AlreadyListed(address nftAddress);
error NoProceeds();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();
error NotApproved();



contract NFTMarketplace is Context {

    // state variables
    uint256 public counter;
    mapping(address => Listing) private s_listings;
    mapping(address => uint256) private s_proceeds; // s_proceeds => amount of ether earned by the seller



    struct Listing {
        uint256 price;
        address seller;
    }

    // some events
    event LogItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 price
    );

    event LogItemCanceled(
        address indexed seller,
        address indexed nftAddress
    );

    event LogItemBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 price,
        int256 fraction
    );

    // funtion modifiers
    modifier isListed(address nftAddress) {
        Listing memory listing = s_listings(nftAddress);
        require(listing.price > 0, "Not listed");
        _;
    }

    modifier notListed(address nftAddress) {
        Listing memory listing = s_listings(nftAddress);
        require(listing.price == 0, "Already listed");
        _;
    }

    modifier isOwner(address nftAddress, address spender) {
        IDN404 nft = IDN404(nftAddress);
        require(nft.balanceOf(spender) > 0, "Not owner");
        _;
    }

    // list items with permit
    function listItemWithPermit(
        address nftAddress,
        uint256 amount,
        int256 price,
        uint256 deadline,
        uint6 v, bytes32 r, bytes32 s
    ) external notListed(nftAddress) {
        IDN404 nft = IDN404(nftAddress);

        nft.permit(_msgSender(), address(this), amount, deadline, v, r, s);

        if (nft.allowance(_msgSender(), address(this)) < amount) {
            revert NotApproved();
        }
        // store the listing information
        s_listings[nftAddress] = Listing(price, _msgSender());

        // emit event for listed item
        emit LogItemListed(_msgSender(), nftAddress, price);

        // increment counter
        counter++;
    }
    

}