import * as PushAPI from "@pushprotocol/restapi";
import * as ethers from "ethers";
import * as dotenv from "dotenv";

dotenv.config();

const PRIVATE_KEY = process.env.PRIVATE_KEY!;

async function sendNotification(title: string, message: string, recipient: string) {
  const signer = new ethers.Wallet(PRIVATE_KEY);

  try {
    const response = await PushAPI.payloads.sendNotification({
      signer,
      type: 3, // Targeted notification
      identityType: 2, // Direct payload
      notification: {
        title,
        body: message,
      },
      payload: {
        title,
        body: message,
        cta: "",
        img: "",
      },
      recipients: recipient, // User's wallet address
      channel: "eip155:5:YOUR_CHANNEL_ADDRESS", // Replace with your Push channel address
      env: "staging",
    });

    console.log("Notification sent:", response);
  } catch (error) {
    console.error("Failed to send notification:", error);
  }
}

// Example usage
sendNotification("Risk Score Updated", "The risk score for SafeAVS has been updated.", "0xUserAddress");