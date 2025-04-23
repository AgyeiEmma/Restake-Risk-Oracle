#!/bin/bash

# Set the root folder
PROJECT_NAME="restake-risk-oracle"
mkdir $PROJECT_NAME && cd $PROJECT_NAME

# Core folders
mkdir contracts frontend graph scripts test backend

# Contracts
cat > contracts/RRO.sol <<EOL
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract RRO {
    // Placeholder for AVS risk logic and rebalancer
}
EOL

cat > contracts/AVSRegistry.sol <<EOL
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract AVSRegistry {
    // Placeholder for tracking AVS metadata
}
EOL

cat > contracts/MockAVS.sol <<EOL
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MockAVS {
    // Simulate AVS behavior
}
EOL

# Frontend folders
mkdir -p frontend/src/{components,pages,services,hooks,constants} frontend/public frontend/styles

cat > frontend/src/pages/index.tsx <<EOL
export default function Home() {
  return <div>Welcome to RRO Dashboard</div>;
}
EOL

cat > frontend/src/components/RiskScoreCard.tsx <<EOL
export const RiskScoreCard = () => {
  return <div>Risk Score</div>;
};
EOL

cat > frontend/src/components/PortfolioOverview.tsx <<EOL
export const PortfolioOverview = () => {
  return <div>Portfolio Overview</div>;
};
EOL

cat > frontend/src/components/RebalanceForm.tsx <<EOL
export const RebalanceForm = () => {
  return <div>Rebalance Settings</div>;
};
EOL

cat > frontend/src/services/riskCalculator.ts <<EOL
export function calculateRiskScore(avs: any) {
  return Math.floor(Math.random() * 100); // Placeholder
}
EOL

cat > frontend/src/constants/config.ts <<EOL
export const AVS_LIST = ["AVSStable", "AVSVolatile", "AVSOffline"];
EOL

cat > frontend/src/hooks/usePortfolio.ts <<EOL
export const usePortfolio = () => {
  return { rswETH: 1.5, swBTC: 0.2 };
};
EOL

cat > frontend/tailwind.config.js <<EOL
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx}"],
  theme: { extend: {} },
  plugins: [],
};
EOL

# Graph
cat > graph/schema.graphql <<EOL
# Placeholder for subgraph schema
type AVS @entity {
  id: ID!
  riskScore: Int!
}
EOL

cat > graph/subgraph.yaml <<EOL
# Placeholder subgraph config
specVersion: 0.0.2
schema:
  file: ./schema.graphql
EOL

# Scripts
cat > scripts/deploy.ts <<EOL
// deploy.ts - deploy RRO contract to Swellchain
async function main() {
  console.log("Deploying RRO...");
}
main();
EOL

cat > scripts/simulateAVS.ts <<EOL
// simulateAVS.ts - fake AVS failure
console.log("Simulating AVS failure...");
EOL

cat > scripts/rebalance.ts <<EOL
// rebalance.ts - trigger smart rebalance
console.log("Triggering rebalance...");
EOL

# Backend
cat > backend/alert-service.ts <<EOL
// alert-service.ts - Push Protocol logic
console.log("Push alert service running...");
EOL

# Tests
cat > test/RRO.test.ts <<EOL
describe("RRO Contract", () => {
  it("should deploy", async () => {
    console.log("Deploy test...");
  });
});
EOL

# Env and configs
touch .env
cat > README.md <<EOL
# 🛡️ Restake Risk Oracle (RRO)

See full documentation inside the repo.
EOL

cat > hardhat.config.ts <<EOL
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.26",
  networks: {
    swell: {
      url: process.env.RPC_URL || "",
      accounts: [process.env.PRIVATE_KEY || ""],
      chainId: 1923,
    },
  },
};

export default config;
EOL

touch package.json tsconfig.json

echo "✅ RRO project initialized in ./$PROJECT_NAME"
