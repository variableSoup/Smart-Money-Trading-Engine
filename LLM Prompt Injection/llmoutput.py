# insider_prompt_simple.py
# Usage: python insider_prompt_simple.py
from google.cloud import bigquery
from datetime import date
import os

# hardcoded params (change if you want)
LOOKBACK_DAYS = 250
TOP_N = 5

# hardcoded SQL file paths
SQL_TOP_CONGRESS = "top_congress_traders.sql"
SQL_TOP_SENATE   = "top_senate_traders.sql"
SQL_BULLISH_SECT = "bullish_sectors.sql"
SQL_DARK_POOL    = "dark_pool_overnight.sql"

def load_sql(path: str) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def run_query(client, sql_text):
    job_cfg = bigquery.QueryJobConfig(
        query_parameters=[
            bigquery.ScalarQueryParameter("lookback_days", "INT64", LOOKBACK_DAYS),
            bigquery.ScalarQueryParameter("top_n", "INT64", TOP_N),
        ]
    )
    return client.query(sql_text, job_config=job_cfg).result()

def main():
    client = bigquery.Client()  # use your default project/creds, no envs

    # run queries (minimal; if a query errors, we just show a stub in the prompt)
    try:
        q_congress = list(run_query(client, load_sql(SQL_TOP_CONGRESS)))
    except Exception as e:
        q_congress = []
    try:
        q_senate = list(run_query(client, load_sql(SQL_TOP_SENATE)))
    except Exception as e:
        q_senate = []
    try:
        q_bullish = list(run_query(client, load_sql(SQL_BULLISH_SECT)))
    except Exception as e:
        q_bullish = []
    try:
        q_darkpool = list(run_query(client, load_sql(SQL_DARK_POOL)))
    except Exception as e:
        q_darkpool = []

    # build the prompt
    today = date.today().isoformat()
    lines = []
    lines.append(f"🕵️ Insider & Dark-Pool Brief — {today} | Lookback: {LOOKBACK_DAYS}d\n")

    # congress
    lines.append("🏛️ Top House (Congress) Traders")
    if q_congress:
        for r in q_congress:
            party = f" ({r.party})" if hasattr(r, "party") and r.party else ""
            domsec = getattr(r, "dominant_sector", None) or "Unknown"
            net = r.net_usd if hasattr(r, "net_usd") else 0
            net_fmt = f"{net:+,.0f}"
            top_list = getattr(r, "top_list", None) or "—"
            lines.append(f"• {r.entity_name}{party} — Net ${net_fmt} — Dominant: {domsec} — Top: {top_list}")
    else:
        lines.append("• No recent Congress trades found or query failed.")

    lines.append("")  # spacer

    # senate
    lines.append("🏛️ Top Senate Traders")
    if q_senate:
        for r in q_senate:
            domsec = getattr(r, "dominant_sector", None) or "Unknown"
            net = r.net_usd if hasattr(r, "net_usd") else 0
            net_fmt = f"{net:+,.0f}"
            top_list = getattr(r, "top_list", None) or "—"
            lines.append(f"• {r.entity_name} — Net ${net_fmt} — Dominant: {domsec} — Top: {top_list}")
    else:
        lines.append("• No recent Senate trades found or query failed.")

    lines.append("")

    # bullish sectors
    lines.append("📈 Most Bullish Sectors (Politicians)")
    if q_bullish:
        pos = [f"{row.sector} (${row.net_usd:,.0f})" for row in q_bullish if getattr(row, "net_usd", 0) and row.net_usd > 0]
        if pos:
            lines.append("• " + "  |  ".join(pos))
        else:
            lines.append("• None positive in window.")
    else:
        lines.append("• Sector rollup unavailable.")

    lines.append("")

    # dark pool
    lines.append("🌒 Dark-Pool (Off-Exchange)")
    if q_darkpool:
        r = q_darkpool[0]
        trade_date = getattr(r, "trade_date", None)
        if trade_date:
            lines.append(f"• As of {trade_date}")
        lines.append(f"• Highest DPI z-score: {getattr(r, 'top_dpi_list', '—')}")
        lines.append(f"• Highest Short Ratio: {getattr(r, 'top_short_list', '—')}")
    else:
        lines.append("• No off-exchange summary available.")

    prompt_text = "\n".join(lines)
    print(prompt_text)

if __name__ == "__main__":
    main()

