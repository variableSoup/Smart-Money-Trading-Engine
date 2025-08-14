# 🤖 SMTE ML Training Data Phase

> This phase prepares our engineered features into clean, labeled training data for machine learning models.

---

## 🧪 What Happens Here

Once features are created, we move into **building ML-ready datasets**, which includes:

- 🧹 Selecting useful features (normalized + lag-free)
- 🏷️ Generating labels for supervised learning:
  - ✅ **Binary labels** (e.g. net_buy_today: 1/0)
  - 📈 **Continuous labels** (e.g. % price move after 3 days)
- 📦 Packaging data into a training-ready format (wide or long tables)

---

## 🛠️ Tools Used

- BigQuery SQL for label generation  
- Feature + label joins using `JOIN` and `WINDOW` functions  
- Vertex AI or export to CSV/Parquet for local model training

---

## ✅ Example Labels

| Label Name         | Type     | Description                                  |
|--------------------|----------|----------------------------------------------|
| `net_buy_binary`   | Binary   | 1 if total net amount traded > 0             |
| `price_change_3d`  | Numeric  | % change in price 3 days after the trade     |
| `volume_spike`     | Binary   | 1 if trade volume is 2× above rolling mean   |

---

## 🧠 Why It Matters

Proper labels turn the pipeline into something predictive — allowing us to:

- Train models to detect **buy/sell signals**
- Forecast **price reactions to insider moves**
- Use LLMs more accurately with **label-informed prompts**

---

_© 2025 SMMSE – Where features meet foresight ☁️_
