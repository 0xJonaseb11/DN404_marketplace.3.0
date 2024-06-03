const { ethers } = require("hardhat");
const fs = require("fs");

const main = async() => {
  const [deployer] = await ethers.getSigners();
  const name = "Meta";
  const symbol = "Meta";
  const maxSupply = ethers.parseEther("50");
  const publicPrice = ethers.parseEther("0");
  const initialTokenSupply = ethers.parseEther("0");
  const signer = deployer.address;

  const argumentsArray = [
    name, 
    symbol, 
    maxSupply.toString(), 
    publicPrice.toString(), 
    initialTokenSupply.toString(), 
    signer
  ];

  const content = "module.exports = " + JSON.stringify(argumentsArray, null, 2) +";";
  fs.writeFileSync("./arguments.js", content);

  console.log("Arguments.js file generated successfully");

  console.log("Deploying contract with account:", deployer.address);

  const Token = await ethers.getContractFactory("NFTMintDN404";
    const token = await Token.deploy(
      name,
      symbol,
      maxSupply,
      publicPrice,
      initialTokenSupply,
      signer
    );

    console.log("Fractionalized NFT deployed to:", await token.getAddress());
}

const runMain = async() => {
  try {
    await main();
    process.exit(0);
  } catch(err) {
    console.error("Error deploying Token contract", err);
    process.exit(1);
  }
}

runMain();