const { ethers } = require("hardhat");

const main = async() => {

    const [deployer] = await ethers.getSigners();

    console.log("Deploying contract with account:", deployer.address);

    const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
    const nftMarketplace = await NFTMarketplace.deploy();

    console.log("NFTMarketplace contract deployed to:", await nftMarketplace.getAddress());
}

const runMain = async() => {
    try {
        await main();
        process.exit(0);
    } catch(err) {
        console.error("Error deploying NFTMarketplace contract",err);
        process.exit(1);
    }
}

runMain();