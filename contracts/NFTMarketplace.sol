// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import 'hardhat/console.sol';

/**
 * This file was generated with Openzeppelin Wizard and later modified.
 * GO TO: https://wizard.openzeppelin.com/#erc20
 */
contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.0015 ether;

    address payable owner;

    mapping (uint256 => MarketItem) idmarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        bool sold
    }

    event idMarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    modifier  onlyOwner {
        require(msg.sender == owner, "only owner of the marketplace can change the listing price");
        _;
    }

    constuctor() ERC721("NFT Metavarse token", "MTNFT") {
        owner == payable(msg.sender);
    }

    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner {
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns(uint256) {
        return listingPrice;
    }

    //create nft token function
    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        return newTokenId;
    }

    function createmarketItem(uint256 tokenURI, uint256 price) private {
        require(price > 0, "Price must be atleast 1");
        require(msg.sender == listingPrice, "Price must be equal to listing price");

        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false,
        );

        _transfer(msg.sender, address(this), tokenId);

        emit idMarketItemCreated(tokenId, msg.seller, addres(this), price, false);

        // function for resale token
        function namreSellToken(uint256 tokenId, uint256 price) public payable {
            require(idMarketItem[tokenId].owner == msg.sender, "Only item owner can perform operation");
            require(msg.value == listingPrice, "Price must be equal to listing");

            idMarketItem[tokenId].sold = false;
            idMarketItem[tokenId].price = price;
            idMarketItem[tokenId].seller = payable(msg.sender);
            idmarketItem[tokenId].owner = payable(address(this));

            _itemsSold.decrement();

            _transfer(msg.sender, address(this), tokenId);

        }

        // create market sale

        function createMarketSale(uint256 tokenId) public payable {
            uint256 price = idMarketItem[tokenId].price,

            require(msg.value == price, "Please submit the asking price in order to coplete ");

            idMarketItem[tokenId].owner = payable(msg.sender);
            idMarketItem[tokenId].sold = true;
            idMarketItem[tokenId].owner = payable(address(0));

            _itemsSold.increment();

            _transfer(address(this), msg.sender, tokenId);

            payable(owner).transfer(listingPrice);
            payable(idMarketItem[tokenId].seller).transfer(msg.value);
        };

        // getting unsold nft data
        function fetchMarketItem() public view returns (MarketItem[] memory) {
            uint256 itemCount = _tokenIds.current();
            uint256 unSoldItemCount = _tokenIds.current(); - _itemsSold.current();
            uint256 currentIndex = 0;

            MarketItem [] memory items = new MarketItem[](unSoldItemCount);
            for (uint256 i = 0; i < itemCount; i++) {
                if(idMarketItem{i + 1}.owner == address(this)) {
                    uint256 currentId = i + 1;

                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;
                }
            }
        }

    }
}
