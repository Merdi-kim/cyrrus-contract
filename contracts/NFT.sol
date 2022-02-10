//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;


    constructor(address marketPlaceAddress) ERC721("CYRRUS TOKEN", "CYT") {
        contractAddress = marketPlaceAddress;
    }

    function setToken(string memory tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint itemId = _tokenIds.current();
        _safeMint(msg.sender, itemId);
        _setTokenURI(itemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return itemId;
    }

}
