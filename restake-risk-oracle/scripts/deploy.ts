import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("🚀 Deploying contract with:", deployer.address);

  const RRO = await ethers.getContractFactory("RRO");
  const contract = await RRO.deploy();

  await contract.deployed();
  console.log("✅ RRO deployed to:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
