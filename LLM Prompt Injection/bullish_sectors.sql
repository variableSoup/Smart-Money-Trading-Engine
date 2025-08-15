WITH union_trades AS (
  SELECT transaction_date AS ds,
         UPPER(ticker)    AS ticker,
         (COALESCE(amount_mid,0) * action_side) AS net_usd
  FROM `stage.congress`
  WHERE transaction_date >= DATE '2024-01-01'

  UNION ALL

  SELECT transaction_date AS ds,
         UPPER(ticker)    AS ticker,
         (COALESCE(amount_mid,0) * action_side) AS net_usd
  FROM `stage.senate`
  WHERE transaction_date >= DATE '2024-01-01'
),
sector_map AS (
  SELECT 'NVDA' AS ticker, 'Semiconductors' AS sector UNION ALL
  SELECT 'AAPL','Consumer Electronics' UNION ALL
  SELECT 'MSFT','Software' UNION ALL
  SELECT 'AMZN','Internet Retail' UNION ALL
  SELECT 'GOOGL','Interactive Media' UNION ALL
  SELECT 'META','Interactive Media' UNION ALL
  SELECT 'TSLA','Automobiles' UNION ALL
  SELECT 'AMD','Semiconductors' UNION ALL
  SELECT 'GE','Industrials' UNION ALL
  SELECT 'MDLZ','Food Products'
)
SELECT
  COALESCE(s.sector,'Unknown') AS sector,
  SUM(u.net_usd)               AS net_usd
FROM union_trades u
LEFT JOIN sector_map s USING (ticker)
GROUP BY sector
ORDER BY net_usd DESC
LIMIT 10;
