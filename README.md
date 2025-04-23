# 🛡️ Restake Risk Oracle (RRO)

**Empowering restakers with real-time risk transparency and automated yield optimization across Swellchain.**

## 📌 Overview

Restake Risk Oracle (RRO) is a smart contract + dashboard system designed to help users navigate the restaking ecosystem safely. It monitors and analyzes the risk levels of various AVSs (Actively Validated Services) on protocols like **Swellchain** and **EigenLayer**, assigning each a real-time Risk Score.

By combining **risk scoring**, **automated rebalancing**, and a sleek dashboard UI, RRO ensures that users maximize their yields while minimizing slashing risk — especially when restaking assets like `rswETH`.

---

## ✨ Features

- 🔍 **AVS Risk Score Engine:** Computes real-time Risk Scores based on validator uptime, slashing history, and performance.
- 📊 **Interactive Dashboard:** Displays risk/yield stats, allocation breakdowns, and optimization sliders.
- 🤖 **Smart Rebalancer:** Automatically shifts user funds across AVSs based on defined risk tolerance and yield goals.
- 🔔 **Push Alerts:** Warns users when AVS risks spike or rewards fall below thresholds.
- 🧩 **Gamified UX:** Earn badges for maintaining an optimized, low-risk portfolio.
- 🌐 **DeFi Integrations:** Route restaked assets into yield-generating pools (e.g., Velodrome, Yearn).

---

## ⚙️ Tech Stack

| Layer             | Tools Used                         |
| ----------------- | ---------------------------------- |
| Smart Contracts   | Solidity, Hardhat                  |
| Blockchain        | Swellchain Testnet (Optimism L2)   |
| Frontend          | Next.js, React, Tailwind CSS       |
| Wallet Connect    | Wagmi.sh, Viem                     |
| Oracles           | Chainlink (mocked for now)         |
| Data Layer        | The Graph (optional)               |
| Notifications     | Push Protocol                      |
| Rebalancing Logic | Custom Smart Contract + JS service |

---

## 🚀 Getting Started

### 1. Clone the Repo

```bash
git clone https://github.com/YOUR_USERNAME/restake-risk-oracle.git
cd restake-risk-oracle
```
