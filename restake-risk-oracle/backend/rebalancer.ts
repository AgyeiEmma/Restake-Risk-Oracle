import { ethers } from "ethers";
import * as dotenv from "dotenv";

dotenv.config();

const RPC_URL = process.env.RPC_URL!;
const PRIVATE_KEY = process.env.PRIVATE_KEY!;
const BACKEND_ADDRESS = process.env.BACKEND_ADDRESS!;

async function getUsers(): Promise<string[]> {
  const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
  const contract = new ethers.Contract(BACKEND_ADDRESS, ["function getAllUsers() view returns (address[])"], provider);

  try {
    const users: string[] = await contract.getAllUsers();
    console.log("Fetched users:", users);
    return users;
  } catch (error) {
    console.error("Failed to fetch users:", error);
    return [];
  }
}

async function triggerRebalancing() {
  const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
  const contract = new ethers.Contract(BACKEND_ADDRESS, ["function triggerRebalance(address user)"], wallet);

  const users = await getUsers(); // Fetch users dynamically
  for (const user of users) {
    try {
      const tx = await contract.triggerRebalance(user);
      console.log(`Triggered rebalancing for ${user}: ${tx.hash}`);
    } catch (error) {
      console.error(`Failed to trigger rebalancing for ${user}:`, error);
    }
  }
}

// Run periodically
setInterval(triggerRebalancing, 30 * 60 * 1000); // Every 30 minutes