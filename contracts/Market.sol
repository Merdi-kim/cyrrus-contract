//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract Market is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    address payable owner; 
    uint256 listingFee = 0.2 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    struct Item {
        uint itemId;
        address nftContract;
        uint tokenId;
        address payable owner;
        uint price;
        bool onSale;
    }

    mapping(uint => Item) private MarketItem_Ids;  

    function mintNFT(address _nftContract, uint _tokenId, uint _price) public nonReentrant {
        require(_price > 0, "Price must be at least 1 wei");
        _itemIds.increment();
        uint itemId = _itemIds.current();
        MarketItem_Ids[itemId] = Item(itemId, _nftContract, _tokenId, payable(msg.sender), _price, true);
    }

    function buyNFT(address _nftContract, uint _itemId) public payable {
        uint price = MarketItem_Ids[_itemId].price;
        uint tokenId = MarketItem_Ids[_itemId].tokenId;
        require(msg.value == price, "You must pay the price of the item");
        MarketItem_Ids[_itemId].owner.transfer(msg.value - listingFee);
        IERC721(_nftContract).safeTransferFrom(MarketItem_Ids[_itemId].owner,msg.sender, tokenId);
        MarketItem_Ids[_itemId].owner = payable(msg.sender);
        MarketItem_Ids[_itemId].onSale = false;
        owner.transfer(listingFee);
    }

    function listForSale(uint itemId) public {
        MarketItem_Ids[itemId].onSale = true;
    }

    function fetchNFTs() public view returns (Item[] memory) {
        uint itemCount = _itemIds.current();
        uint currentIndex = 0;
        Item[] memory items = new Item[](itemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (MarketItem_Ids[i].onSale) {
                items[currentIndex] = MarketItem_Ids[i];
                currentIndex++;
            }
        }

        return items;
    }

    function fetchMyNfts() public view returns (Item[] memory) {
        uint itemCount = 0;
        uint currentIndex = 0;
        uint totalItems =_itemIds.current();
        for (uint i = 0; i < totalItems; i++) {
            if(MarketItem_Ids[i+1].owner == msg.sender) {
                itemCount += 1;
            }  
        }
        Item[] memory items = new Item[](itemCount);
        for (uint i = 0; i < totalItems; i++) {
            if (MarketItem_Ids[i +1].owner == msg.sender) {
                uint currentId = MarketItem_Ids[i+1].itemId;
                Item storage currentItem = MarketItem_Ids[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }
}