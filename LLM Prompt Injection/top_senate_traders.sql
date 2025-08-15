-- Inputs: @top_n INT64
WITH recent AS (
  SELECT
    entity_name,
    UPPER(ticker) AS ticker,
    COALESCE(amount_mid,0) AS amount_mid,
    action_side,
    transaction_date
  FROM `stage.senate`  -- change to `stage.senate_trades` if that's your table
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
),
per_entity_ticker AS (
  SELECT
    entity_name,
    ticker,
    SUM(amount_mid * action_side) AS net_usd
  FROM recent
  GROUP BY 1,2
),
joined AS (
  SELECT
    p.entity_name,
    p.ticker,
    p.net_usd,
    COALESCE(s.sector,'Unknown') AS sector
  FROM per_entity_ticker p
  LEFT JOIN sector_map s USING (ticker)
),
entity_total AS (
  SELECT entity_name, SUM(net_usd) AS net_usd
  FROM joined
  GROUP BY entity_name
),
dominant_sector AS (
  SELECT entity_name, sector
  FROM (
    SELECT
      entity_name, sector,
      SUM(net_usd) AS sector_net,
      ROW_NUMBER() OVER (PARTITION BY entity_name ORDER BY SUM(net_usd) DESC) AS rn
    FROM joined
    GROUP BY entity_name, sector
  )
  WHERE rn = 1
),
top_tickers AS (
  SELECT
    entity_name,
    STRING_AGG(
      FORMAT('%s (%s) %s', ticker, sector, CAST(net_usd AS STRING)),
      ', '
      ORDER BY net_usd DESC
    ) AS top_list
  FROM (
    SELECT
      j.*,
      ROW_NUMBER() OVER (PARTITION BY entity_name ORDER BY net_usd DESC) AS rn
    FROM joined j
  )
  WHERE rn <= @top_n
  GROUP BY entity_name
)
SELECT
  et.entity_name,
  et.net_usd,
  ds.sector AS dominant_sector,
  COALESCE(tt.top_list, '—') AS top_list
FROM entity_total et
LEFT JOIN dominant_sector ds USING (entity_name)
LEFT JOIN top_tickers   tt USING (entity_name)
ORDER BY et.net_usd DESC
LIMIT @top_n;
