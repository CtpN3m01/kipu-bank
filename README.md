# KipuBank 🏦

*A minimal, security‑first ETH vault.*

KipuBank lets anyone **deposit** and later **withdraw** native Ether from a personal vault, under two immutable limits:

1. **Per‑transaction withdrawal limit** (`withdrawLimit`)
2. **Global bank cap** (`bankCap`)

The contract is fewer than 144 lines yet follows every modern Solidity recommendation: custom errors, modifiers, CEI ordering, NatSpec, and safe low‑level `call` transfers.

---

## 🚀 Quick Deployment

| Item | Value |
|------|-------------------|
| **Network** | `Sepolia` |
| **Contract address** | `0xaed145cbfc837b1cef95cff8ab78c21e4806a1ac` |
| **Creation Tx hash** | `0x77d5586b10d2e736906932c3db1bba5484f91a6124f9ecd282ed6bb138f59ae0` |
| **Source verified** | `<❌>` |


## ✨ Feature Overview

| 🛠 Feature | What it does |
|-----------|--------------|
| 🔒 **Per‑tx cap** | Hard limit enforced by `withdrawLimit` (`immutable`). |
| 🏦 **Global cap** | `withinBankCap` modifier stops deposits once `bankCap` is reached. |
| 📣 **Events** | `Deposited` & `Withdrawn` with `indexed` user for easy off‑chain indexing. |
| 📊 **Counters** | `depositCount`, `withdrawalCount`, plus global `totalDeposited/Withdrawn`. |
| 🛡 **Custom errors** | Cheaper & clearer than `require("string")`. |
| ⚖️ **CEI pattern** | State changes before external calls to block re‑entrancy. |
| 💸 **Safe send** | ETH moved via `call{value: ...}` + `require(ok)`. |
| 📜 **NatSpec docs** | Wallets & explorers display human‑readable comments. |

---

## 🔧 How to Deploy (Remix)

1. **Open** <https://remix.ethereum.org/> and paste `KipuBank.sol` in `/contracts`.
2. In **Solidity Compiler** ➜ select `0.8.26` + *Enable Optimization*.
3. In **Deploy & Run**:
   - Environment: *Injected Provider – MetaMask*.
   - Constructor params:
     - `_withdrawLimit` → `1000000000000000000` (= 1 ETH)
     - `_bankCap` → `100000000000000000000` (= 100 ETH)
4. Click **Deploy**, wait for MetaMask confirmation.
---

## 💬 Interacting

| Action | Steps |
|--------|-------|
| **Deposit** | In Etherscan ➜ *Write Contract* ➜ `deposit()` ➜ send ≥ `0.001 ETH`. |
| **Withdraw** | `withdraw(uint256)` with an amount ≤ `withdrawLimit`. |
| **Check balance** | *Read Contract* ➜ `vaultBalance(address)` with your wallet addr. |
| **Stats** | View `totalDeposited`, `totalWithdrawn`, `depositCount`, `withdrawalCount`. |

---

## 🗂 Project Layout

```text
contracts/
└─ KipuBank.sol        # core contract
README.md              # you are here

```

## 📄 License

Released under the **MIT** License. Feel free to fork, audit, and improve.
