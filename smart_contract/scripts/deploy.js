const { ethers } = require("hardhat");
const fs = require("fs");

const main = async() => {
  const [deployer] = await ethers.getSigners();
  const name = "Meta";
  const symbol = "Meta";
  const maxSupply = ethers.parseEther("50");
  const publicSupply = ethers.parseEther("0");
}