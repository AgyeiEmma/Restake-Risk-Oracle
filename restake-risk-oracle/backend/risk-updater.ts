import { ethers } from "ethers";
import * as dotenv from "dotenv";

dotenv.config();

const RPC_URL = process.env.RPC_URL!;
const PRIVATE_KEY = process.env.PRIVATE_KEY!;
const BACKEND_ADDRESS = process.env.BACKEND_ADDRESS!;

async function updateRiskScores() {
  const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
  const contract = new ethers.Contract(BACKEND_ADDRESS, ["function updateRiskScoreFromOracle(string avsName)"], wallet);

  const avsList = ["SafeAVS", "RiskyAVS"]; // Replace with dynamic fetching logic
  for (const avs of avsList) {
    try {
      const tx = await contract.updateRiskScoreFromOracle(avs);
      console.log(`Updated risk score for ${avs}: ${tx.hash}`);
    } catch (error) {
      console.error(`Failed to update risk score for ${avs}:`, error);
    }
  }
}

// Run periodically
setInterval(updateRiskScores, 60 * 60 * 1000); // Every hour