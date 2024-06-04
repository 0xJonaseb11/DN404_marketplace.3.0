const { ethers } = require("hardhat");
const fs = require("fs");

const main = async() => {
  
  const [deployer] = await ethers.getSigners();
  const name = "Meta";
  const symbol = "Meta";
  const uri = "ipfs://QmTNgv3jx2HHfBjQX9RnKtxj2xv2xQDtbVXoRi5rJ3a46e";
  const maxSupply = ethers.parseEther("50");
  const publicPrice = ethers.parseEther("0");
  const initialTokenSupply = ethers.parseEther("0");
  const signer = deployer.address;

  const argumentsArray = [
    name, 
    symbol, 
    uri,
    maxSupply.toString(), 
    publicPrice.toString(), 
    initialTokenSupply.toString(), 
    signer
  ];

  const content = "module.exports = " + JSON.stringify(argumentsArray, null, 2) +";";
  fs.writeFileSync("./arguments.js", content);

  console.log("Arguments.js file generated successfully");

  console.log("Deploying contract with account:", deployer.address);

  const Token = await ethers.getContractFactory("NFTMintDN404");
  const token = await Token.deploy(
    name,
    symbol,
    uri,
    maxSupply,
    publicPrice,
    initialTokenSupply,
    signer
  );

  console.log("Fractionalized NFT deployed to:", await token.getAddress());

  /*

  // Get the base URI
   console.log("Contract Metadata URI:", baseURI);

  // Save the contract address and base URI to a file
  const contractInfo = {
    address: await token.getAddress(),
    baseURI: baseURI
  };
  

  fs.writeFileSync("contract-info.json", JSON.stringify(contractInfo, null, 2));
  console.log("Contract information saved to contract-info.json");

  */
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
