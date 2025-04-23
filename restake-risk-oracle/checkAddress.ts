import { ethers } from "ethers";

async function main() {
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const balance = await wallet.getBalance();
  console.log(`Account balance: ${ethers.utils.formatEther(balance)} ETH`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
