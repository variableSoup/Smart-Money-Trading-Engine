# 🧠 Government Insider Trading Engine (GITE)

![Google Cloud](https://upload.wikimedia.org/wikipedia/commons/5/5f/Google_Cloud_logo.png)

> 🎯 **A personal Google Cloud project to showcase cloud data pipelines, Machine Learning, and AI prompt injection — using real insider government trading data.**

---

## 👋 What’s This All About?

This is **GITE**, a solo-built project that:

- 🏛️ Ingests insider government trades (yes, from Congress!) using the **Quiver API**
- ☁️ Uses **BigQuery** and **Machine Learning** on **Google Cloud** to transform and analyze that data
- 📊 Engineers features and insights from the raw data to make it actually useful
- 🧠 Ability to summarize into a **language model (LLM)** that interprets the data in plain English

> My goal? Show how a cloud-based pipeline can turn complex financial data into something readable and informative.

---

## 🧬 What Does It Do?

Every weekday:

✅ Pulls fresh insider trading data from QuiverQuant (Congress, Senate, House)  
✅ Stores and queries the data using BigQuery  
✅ Applies basic ML logic to extract sentiment and trends (e.g. "sector X is being heavily bought")  
✅ Generates engineered views like:
- Net flow by sector
- Most active tickers
- Trade volume by political party  
✅ Can also inject all that context into a prompt-ready format so your LLM can interpret it however you want

---

## 🗺️ System Flow

![SMMSE Pipeline](https://raw.githubusercontent.com/your-username/your-repo-name/main/docs/SMMSE_architecture.png)

---

## 🛠️ Tech Breakdown

| 🧰 Tool         | 💡 Role                            |
|----------------|------------------------------------|
| Google Cloud   | Infrastructure + Automation        |
| BigQuery       | SQL Analysis + Feature Engineering |           |
| Python         | Glue code + scheduling             |
| Quiver API     | Insider Trading Data Source        |

---

## 🔥 Why This Is Cool (and Not Just for Fun)

- 📡 Tracks the real moves of government insiders in the market  
- 📈 Converts obscure filings into simple summaries via LLMs  
- ☁️ Uses **real serverless tools** (not mockups!) for production-grade workflows  
- 🧱 A real-world project to flex **data science + ML + cloud** muscles  

---

## 🎯 Who’s This For?

- 🧑‍💼 Recruiters looking for someone with **GCP, ML, and AI integration** experience  
- 🧪 Data scientists wanting a reference project for **feature engineering + pipeline orchestration**  
- 🧠 LLM builders who want **structured prompt-ready finance summaries**

> 📌 This is NOT a commercial product. It’s a portfolio project to showcase serious skill.

---

## 💬 Example Use Case

After the pipeline finishes, an LLM receives prompts like:

