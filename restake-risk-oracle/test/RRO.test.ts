import { expect } from "chai";
import { ethers } from "hardhat";
import { RRO } from "../typechain-types/RRO";

describe("RRO Contract", () => {
  let contract: RRO;
  let deployer: any;
  let user: any;
  let trustedBackend: any;

  beforeEach(async () => {
    // Get signers
    [deployer, user, trustedBackend] = await ethers.getSigners();

    // Deploy the contract
    const RROFactory = await ethers.getContractFactory("RRO");
    contract = (await RROFactory.deploy(trustedBackend.address)) as RRO;
    await contract.deployed();
  });

  it("should trigger rebalancing for a user", async () => {
    // Set user preferences
    await contract.connect(user).setUserPreferences(50);

    // Register AVSs
    await contract.connect(deployer).registerAVS("SafeAVS", 30);
    await contract.connect(deployer).registerAVS("RiskyAVS", 70);

    // Deposit funds into RiskyAVS
    await contract.connect(user).depositToAVS("RiskyAVS", ethers.utils.parseEther("1"));

    // Trigger rebalancing
    const tx = await contract.connect(trustedBackend).triggerRebalance(user.address);
    await tx.wait();

    // Check balances after rebalancing
    const safeBalance = await contract.userBalances(user.address, "SafeAVS");
    const riskyBalance = await contract.userBalances(user.address, "RiskyAVS");

    expect(safeBalance).to.equal(ethers.utils.parseEther("1"));
    expect(riskyBalance).to.equal(0);
  });

  it("should validate AVS registration inputs", async () => {
    await expect(contract.registerAVS("", 50)).to.be.revertedWith("AVS name cannot be empty");
    await expect(contract.registerAVS("A".repeat(33), 50)).to.be.revertedWith("AVS name too long");
    await expect(contract.registerAVS("ValidAVS", 101)).to.be.revertedWith("Invalid risk score");
  });

  it("should validate user preferences inputs", async () => {
    await expect(contract.setUserPreferences(0)).to.be.revertedWith("Risk score must be greater than 0");
    await expect(contract.setUserPreferences(101)).to.be.revertedWith("Invalid threshold");
  });
});
