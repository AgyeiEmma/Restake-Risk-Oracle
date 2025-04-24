import * as dotenv from "dotenv";
import { ethers } from "hardhat";
dotenv.config();

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("🚀 Deploying contracts with:", deployer.address);

  // Deploy the mock oracle
  const MockOracle = await ethers.getContractFactory("MockOracle");
  const mockOracle = await MockOracle.deploy(50); // Initial risk score
  await mockOracle.deployed();
  console.log("✅ MockOracle deployed to:", mockOracle.address);

  // Deploy the RRO contract
  const trustedBackend = process.env.BACKEND_ADDRESS!;
  const RRO = await ethers.getContractFactory("RRO");
  const contract = await RRO.deploy(trustedBackend);
  await contract.deployed();
  console.log("✅ RRO deployed to:", contract.address);

  // Set the mock oracle in the RRO contract
  await contract.setRiskScoreOracle(mockOracle.address);
  console.log("✅ MockOracle set in RRO contract");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
