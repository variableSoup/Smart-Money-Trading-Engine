# 📦 SMTE Data Extraction Phase

> This folder contains the **data ingestion scripts and sample outputs** for the Smart Money Trading Engine (SMTE).

---

## 🔍 What’s Inside?

This folder includes:

- 🐍 Python scripts for fetching & parsing:
  - Insider trading data from QuiverQuant API (for example Congress, Senate, House)
  - Government contracts, lobbying, and news sentiment (if applicable to enrich data further)

- 📁 Sample extracted `.json` and `.ndjson` files in correct structure for Google Cloud ingestion:
  - Cleaned, schema-ready files for BigQuery
  - Organized by source and date

---

## 🚫 Not a Standalone Project

⚠️ This folder is **not meant to be executed** on its own. It simply holds the extraction logic and examples of what the data looks like **after cleaning and parsing**.

---

## 🛠️ Technologies Used

- Python 3.10+
- `requests`, `pandas`, `datetime`, `json`
- Manual scheduling or integration with external schedulers (see main repo)

---
