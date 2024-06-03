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

        // increment counter - listings
        counter++;
    }
    
    // initialize cancel listing functionality
    function cancelListing(address nftAddress) external isOwner(
        nftAddress, _msgSender()) isListed(nftAddress) {
            delete s_listings[nftAddress];
            emit LogItemCanceled(_msgSender(), nftAddress);
    }
    
    // initialize buy nft item functionality
    function buyItem(address nftAddress, uint256 fraction) external payable isListed(nftAddress) {
        Listing memory listedItem = s_listings[nftAddress];
        require(msg.value >= listedItem.price, "Price not met");

        s_proceeds[listedItem].seller += msg.value;
        delete s_listings[nftAddress];
        // transfer fraction from `listedItem.seller` to the buyer
        IDN404(nftAddress).transferFrom(listedItem.seller, _msgSender(), fraction);
        // emit log item bought event
        emit LogItemBought(_msgSender(), nftAddress, listedItem.price, fraction);
    }

    // initialize withdraw earnings(proceeds) functinality
    function withdrawProceeds() external {
        uint256 proceeds = s_proceeds[_msgSender()];
        require(proceeds > 0, "No proceeds found");
        // update state to avoid reentrancy
        s_proceeds[_msgSender()] = 0;

        // safe withdraw
        (bool success, ) = payable(_msgSender()).call{value: proceeds}("");
        require(success, "Transfer failed");
    }

    // initialize utilities
    function getListing(address nftAddress) external view returns(Listing memory) {
        return s_listings[nftAddress];
    }

    function getProceeds(address seller) external view returns(uint256) {
        return s_proceeds[seller];
    }

    // get number of listings
    function numListings() external view returns(uint256) {
        return counter;
    }


    

}