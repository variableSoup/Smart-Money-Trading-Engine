# 🧠 SMTE Feature Engineering Phase

> This phase adds **intelligence and structure** to our staged data — prepping it for machine learning and advanced analysis.

---

## 🧬 What We Do Here

We take the clean, staged data and generate new **features** that help models and humans understand trends, such as:

- 📆 **Daily trade counts** by entity (e.g. per congressperson)
- 🔁 **Rolling 7-day/30-day sums** of trade amounts
- 🏛️ **Group-level activity** (e.g. net flow by political party)
- 📊 **Sector frequency scores** (which industries are being targeted)

---

## 🛠️ Tools Used

- BigQuery SQL for feature transformations  
- Optional: materialized views or feature tables  
- Output ready for ML pipelines, dashboarding, or LLM summarization

---

## ✅ Example Features

