# 🪙 **Earnera** – Automated Royalty Distribution Smart Contract

**Earnera** is a Clarity smart contract designed to streamline and automate royalty distributions for creative works. It empowers creators to register their content, assign revenue shares to stakeholders, and securely distribute royalties based on predefined percentages—all without the need for intermediaries.

---

## ✨ Key Features

* **Work Registration**
  Creators can register original works with a title and royalty rate.

* **Stakeholder Management**
  Assign and manage revenue shares for collaborators, contributors, or investors.

* **Royalty Distribution**
  Automatically distribute royalty payments based on assigned shares using Clarity’s secure logic.

* **Earnings Withdrawal**
  Stakeholders can withdraw their accrued royalties at any time.

* **Error Handling**
  Built-in assertions and error codes ensure secure and predictable behavior.

---

## 🔐 Access Control

* Only the **original creator** of a work can:

  * Add stakeholders
  * Distribute royalties for that work

* Only stakeholders with assigned shares will receive payouts.

---

## 🧱 Contract Components

### Data Structures

* **`works`**: Stores details about registered works.
* **`work-stakeholders`**: Maps each work and stakeholder to their revenue share.
* **`earnings`**: Tracks how much each stakeholder has earned and can withdraw.

### Contract Variables

* **`work-counter`**: Auto-incrementing ID for new works.
* **`contract-owner`**: Initial deployer of the contract.

---

## 📤 Public Functions

* `register-work(title, royalty-rate)`: Registers a new work.
* `add-stakeholder(work-id, stakeholder, share)`: Assigns a stakeholder and share.
* `distribute-royalty(work-id, amount)`: Distributes incoming royalty to stakeholders.
* `withdraw-earnings()`: Allows stakeholders to withdraw accumulated earnings.

---

## 🔍 Read-Only Functions

* `get-work-details(work-id)`: View metadata of a registered work.
* `get-stakeholder-share(work-id, stakeholder)`: Retrieve share info for a stakeholder.
* `get-earnings(account)`: Check current earnings for an account.

---

## ⚠️ Error Codes

| Code | Meaning             |
| ---- | ------------------- |
| 100  | Not authorized      |
| 101  | Invalid work        |
| 102  | Invalid stakeholder |
| 103  | Invalid share       |
| 104  | Shares exceed 100%  |
| 105  | Insufficient funds  |
| 106  | Transfer failed     |

---

## 🧠 Example Workflow

1. **Creator registers a song** with 10% royalty rate using `register-work`.
2. **Adds collaborators** as stakeholders with `add-stakeholder`, distributing up to 100% of incoming royalties.
3. When income is received, **creator calls `distribute-royalty`**.
4. Each stakeholder can **call `withdraw-earnings`** to receive their earnings.

---

## ✅ Use Cases

* Music & Film Royalties
* NFT/Art Collaborations
* Digital Publishing Platforms
* Content Creator Revenue Sharing
* IP Licensing Agreements

---

## 🛠️ Built With

* **[Clarity](https://docs.stacks.co/write-smart-contracts/clarity-overview)** – Predictable, secure smart contract language for Bitcoin

---

## 🧾 License

MIT License — free to use, fork, and build upon.
