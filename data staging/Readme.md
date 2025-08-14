# 🧮 SMTE Data Staging Phase

> Intermediate phase of the SMMSE pipeline — where raw `.ndjson` files are linked to staging tables for further analysis and ML.

---

## 🗂️ Purpose

This step bridges the gap between **raw ingestion** and **machine learning-ready datasets**.

We take structured `.ndjson` files (from the extraction phase) and:

- ✅ Link them to **external BigQuery tables** (no duplication)
- ✅ Apply light transformations (e.g. column renaming, timestamp normalization)
- ✅ Ensure schema compatibility for downstream ML and summarization jobs

---

## 🛠️ What This Includes

- `create_staging_tables.sql` – SQL to define external tables from GCS `.ndjson` files  
- `schema_map` – defines field types and standard naming conventions  
- simple transformations using SQL Views or temporary materializations

---

## 🧠 Why It Matters

By isolating raw → staged data, we can:

- Maintain a **clean separation of concerns**
- Enable **quick experimentation with ML features**
- Avoid re-ingesting or rewriting source files

---

## ✅ Output

- Staging tables in BigQuery, such as:

<img src="https://github.com/variableSoup/Smart-Money-Trading-Engine/blob/main/images/Screenshot%202025-08-14%20062411.png" alt="Description">
