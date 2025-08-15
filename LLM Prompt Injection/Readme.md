# 🧠 SMTE LLM Prompt Injection Phase

> This phase transforms structured market data into **natural language summaries** that large language models (LLMs) can understand and use in responses.

---

## 🧩 What We’re Doing

We combine key financial signals from across the pipeline to produce a **compact, LLM-ready summary**, such as:

- 🏛️ Top government traders (Congress & Senate)
- 🔁 Overnight exchange stats (e.g. SPX/NQ/QQQ movement)
- 🟢 Bullish sector activity (by net flow or trade count)

This summary is then **injected into prompts** used by chatbots or automated reports.

---

## 🛠️ How It Works

- 🔍 SQL queries extract top insights from BigQuery (stored in `.sql` files)
- 🐍 A Python script:
  - Calls each SQL file
  - Parses and formats results
  - Assembles a compact **prompt-friendly summary block**
- 📤 The result is fed directly into an LLM for:
  - 🧠 Response generation
  - 📊 Report enrichment
  - 🤖 AI agent decision-making

---

## 🧠 Sample Prompt Block

```
🕵️ Insider & Dark-Pool Brief — 2025-08-13 | Lookback: 250d

🏛️ Top House (Congress) Traders
• Cleo Fields (D) — Net $+10,673,039 — Dominant: Semiconductors — Top: NVDA (Semiconductors) 5488010, AMZN (Internet Retail) 1133004, MSFT (Software) 990504, AAPL (Consumer Electronics) 906505, GOOG (Unknown) 707503
• Nancy Pelosi (D) — Net $+3,000,000 — Dominant: Unknown — Top: AVGO (Unknown) 3000000.5
• Marjorie Taylor Greene (R) — Net $+281,014 — Dominant: Unknown — Top: UNH (Unknown) 40501, MELI (Unknown) 32500.5, NOW (Unknown) 16001, NFLX (Unknown) 16001, SNOW (Unknown) 16001
• Ashley B. Moody (R) — Net $+250,001 — Dominant: Unknown — Top: AMAT (Unknown) 175000.5, MU (Unknown) 75000.5, HWM (Unknown) 75000.5, OKTA (Unknown) -75000.5
• Tim Moore (R) — Net $+199,006 — Dominant: Unknown — Top: CNC (Unknown) 170503, DNUT (Unknown) 40501, UNH (Unknown) 40501, INTC (Unknown) 32500.5, VZ (Unknown) 32500.5

🏛️ Top Senate Traders
• Ashley B. Moody — Net $+250,001 — Dominant: Unknown — Top: AMAT (Unknown) 175000.5, MU (Unknown) 75000.5, HWM (Unknown) 75000.5, OKTA (Unknown) -75000.5
• John Boozman — Net $+128,506 — Dominant: Interactive Media — Top: TBLL (Unknown) 72503, MSFT (Software) 40002.5, VEA (Unknown) 32500.5, FTGC (Unknown) 32500.5, SCZ (Unknown) 32500.5
• Lindsey Graham — Net $+65,001 — Dominant: Unknown — Top: XONE (Unknown) 32500.5, USFR (Unknown) 32500.5, BSCV (Unknown) 32500.5, VIG (Unknown) -32500.5
• A. Mitchell Jr. McConnell — Net $+15,502 — Dominant: Unknown — Top: WFC (Unknown) 48003, LAZR (Unknown) -32500.5
• Thomas R. Carper — Net $+8,000 — Dominant: Unknown — Top: TGT (Unknown) 16001, ENB (Unknown) 8000.5, OXY (Unknown) 8000.5, NVDA (Semiconductors) 8000.5, ALTM (Unknown) 8000.5

📈 Most Bullish Sectors (Politicians)
• Semiconductors ($5,312,014)  |  Internet Retail ($1,238,008)  |  Software ($473,498)  |  Industrials ($24,002)

🌒 Dark-Pool (Off-Exchange)
• As of 2025-08-13
• Highest DPI z-score:
• Highest Short Ratio: GIGM (sr=1.000 on 2025-04-17), EMCG (sr=1.000 on 2025-04-17), ISRL (sr=1.000 on 2025-04-17), HYAC (sr=1.000 on 2025-04-17), NOM (sr=0.998 on 2025-04-17)```
