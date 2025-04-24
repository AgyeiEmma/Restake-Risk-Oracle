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

  describe("AVS Management", () => {
    it("should allow the owner to register an AVS", async () => {
      await contract.connect(deployer).registerAVS("SafeAVS", 30);
      const avs = await contract.getAVSDetails("SafeAVS");
      expect(avs.avsName).to.equal("SafeAVS");
      expect(avs.baseRiskScore).to.equal(30);
      expect(avs.exists).to.be.true;
    });

    it("should not allow non-owners to register an AVS", async () => {
      await expect(contract.connect(user).registerAVS("SafeAVS", 30)).to.be.revertedWith("Not authorized");
    });

    it("should validate AVS registration inputs", async () => {
      await expect(contract.registerAVS("", 50)).to.be.revertedWith("AVS name cannot be empty");
      await expect(contract.registerAVS("A".repeat(33), 50)).to.be.revertedWith("AVS name too long");
      await expect(contract.registerAVS("ValidAVS", 101)).to.be.revertedWith("Invalid risk score");
    });

    it("should allow the owner to update an AVS risk score", async () => {
      await contract.connect(deployer).registerAVS("SafeAVS", 30);
      await contract.connect(deployer).updateRiskScore("SafeAVS", 40);
      const riskScore = await contract.getRiskScore("SafeAVS");
      expect(riskScore).to.equal(40);
    });

    it("should not allow non-owners to update an AVS risk score", async () => {
      await contract.connect(deployer).registerAVS("SafeAVS", 30);
      await expect(contract.connect(user).updateRiskScore("SafeAVS", 40)).to.be.revertedWith("Not authorized");
    });
  });

  describe("User Preferences", () => {
    it("should allow users to set their preferences", async () => {
      await contract.connect(user).setUserPreferences(50);
      const prefs = await contract.getUserPreferences(user.address);
      expect(prefs.maxRiskScore).to.equal(50);
      expect(prefs.autoRebalance).to.be.true;
    });

    it("should validate user preferences inputs", async () => {
      await expect(contract.connect(user).setUserPreferences(0)).to.be.revertedWith("Risk score must be greater than 0");
      await expect(contract.connect(user).setUserPreferences(101)).to.be.revertedWith("Invalid threshold");
    });
  });

  describe("Rebalancing", () => {
    beforeEach(async () => {
      // Register AVSs
      await contract.connect(deployer).registerAVS("SafeAVS", 30);
      await contract.connect(deployer).registerAVS("RiskyAVS", 70);

      // Set user preferences
      await contract.connect(user).setUserPreferences(50);

      // Deposit funds into RiskyAVS
      await contract.connect(user).depositToAVS("RiskyAVS", ethers.utils.parseEther("1"));
    });

    it("should trigger rebalancing for a user", async () => {
      const tx = await contract.connect(trustedBackend).triggerRebalance(user.address);
      await tx.wait();

      const safeBalance = await contract.userBalances(user.address, "SafeAVS");
      const riskyBalance = await contract.userBalances(user.address, "RiskyAVS");

      expect(safeBalance).to.equal(ethers.utils.parseEther("1"));
      expect(riskyBalance).to.equal(0);
    });

    it("should not allow unauthorized addresses to trigger rebalancing", async () => {
      await expect(contract.connect(user).triggerRebalance(user.address)).to.be.revertedWith("Not authorized");
    });

    it("should not trigger rebalancing if user has not opted in", async () => {
      // Set user preferences with autoRebalance set to false
      await contract.connect(user).setUserPreferences(50); // Default autoRebalance is true
      await contract.connect(user).setUserPreferences(50); // Reset preferences without changing autoRebalance

      // Attempt to trigger rebalancing
      await expect(contract.connect(trustedBackend).triggerRebalance(user.address)).to.be.revertedWith(
        "User has not opted into auto-rebalancing"
      );
    });
  });

  describe("Edge Cases", () => {
    it("should revert if trying to get details of a non-existent AVS", async () => {
      await expect(contract.getAVSDetails("NonExistentAVS")).to.be.revertedWith("AVS not found");
    });

    it("should revert if trying to update risk score of a non-existent AVS", async () => {
      await expect(contract.updateRiskScore("NonExistentAVS", 50)).to.be.revertedWith("AVS not found");
    });

    it("should revert if trying to deposit to a non-existent AVS", async () => {
      await expect(contract.connect(user).depositToAVS("NonExistentAVS", ethers.utils.parseEther("1"))).to.be.revertedWith(
        "AVS not found"
      );
    });
  });

  it("should update risk score using the oracle", async () => {
    // Deploy the mock oracle
    const MockOracle = await ethers.getContractFactory("MockOracle");
    const mockOracle = await MockOracle.deploy(50); // Initial risk score
    await mockOracle.deployed();

    // Set the mock oracle in the RRO contract
    await contract.connect(deployer).setRiskScoreOracle(mockOracle.address);

    // Register an AVS
    await contract.connect(deployer).registerAVS("SafeAVS", 30);

    // Update the risk score using the oracle
    await contract.connect(trustedBackend).updateRiskScoreFromOracle("SafeAVS");

    // Verify the updated risk score
    const riskScore = await contract.getRiskScore("SafeAVS");
    expect(riskScore).to.equal(50);
  });
});
