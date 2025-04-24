import * as dotenv from "dotenv";
import { ethers } from "hardhat";
dotenv.config();

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("🚀 Deploying contract with:", deployer.address);

  const trustedBackend = process.env.BACKEND_ADDRESS!;
  const RRO = await ethers.getContractFactory("RRO");
  const contract = await RRO.deploy(trustedBackend);

  await contract.deployed();
  console.log("✅ RRO deployed to:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
