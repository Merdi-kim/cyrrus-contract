const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Market", function () {
  it('Should create and execute marketplace sales', async function() {
    const MarketRef = await ethers.getContractFactory("Market");
    const market = await MarketRef.deploy();
    await market.deployed();
    const marketAddress = market.address;

    const NFTRef = await ethers.getContractFactory("NFT");
    const nft = await NFTRef.deploy(marketAddress);
    await nft.deployed();
    const nftAddress = nft.address;

    let listingFee = 0.1
    listingFee = listingFee.toString() 

    await nft.setToken('https://www.mytoken1location.com')
    await nft.setToken('https://www.mytoken2location.com')

    await market.mintNFT(nftAddress,1, ethers.utils.parseEther(String(10)))
    await market.mintNFT(nftAddress,2, 100)

    const [_, buyerAddress] = await ethers.getSigners() 

    await market.connect(buyerAddress).buyNFT(nftAddress,1, {value: ethers.utils.parseEther(String(10))})

    const items = await market.fetchNFTs()


    console.log('items:', items)

    expect(items.length).to.equal(2)
  })
})