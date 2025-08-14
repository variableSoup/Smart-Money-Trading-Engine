-- =========================
-- labels.sql (sector-only, no SPY)
-- =========================

-- 0) Make sure the 'labels' dataset exists in the SAME LOCATION as 'stage'
-- CREATE SCHEMA IF NOT EXISTS `labels` OPTIONS(location='US'); -- adjust if needed

-- 1) Normalize sector price tables → labels.prices_norm
--    - Adds a 'sector' column
--    - Uses DATE(date) (your tables have DATE already)
--    - Uses COALESCE(adj_close, close) for robustness
CREATE OR REPLACE TABLE `labels.prices_norm`
PARTITION BY ds
CLUSTER BY ticker, sector AS
WITH unioned AS (
  -- Communications  (note the table name: communcations)
  SELECT 'COMM' AS sector,
         UPPER(ticker) AS ticker,
         DATE(date) AS ds,
         CAST(COALESCE(adj_close, close) AS NUMERIC) AS adj_close
  FROM `stage.communcations`

  UNION ALL
  -- Consumer Discretionary
  SELECT 'CONS_DISC',
         UPPER(ticker),
         DATE(date),
         CAST(COALESCE(adj_close, close) AS NUMERIC)
  FROM `stage.consumerDiscretion`

  UNION ALL
  -- Consumer Staples
  SELECT 'CONS_STAP',
         UPPER(ticker),
         DATE(date),
         CAST(COALESCE(adj_close, close) AS NUMERIC)
  FROM `stage.consumerStaples`

  UNION ALL
  -- Energy
  SELECT 'ENERGY',
         UPPER(ticker),
         DATE(date),
         CAST(COALESCE(adj_close, close) AS NUMERIC)
  FROM `stage.energy`

  UNION ALL
  -- Financials
  SELECT 'FIN',
         UPPER(ticker),
         DATE(date),
         CAST(COALESCE(adj_close, close) AS NUMERIC)
  FROM `stage.financial`

  UNION ALL
  -- Healthcare
  SELECT 'HEALTH',
         UPPER(ticker),
         DATE(date),
         CAST(COALESCE(adj_close, close) AS NUMERIC)
  FROM `stage.healthcare`

  UNION ALL
  -- Industrials
  SELECT 'INDUS',
         UPPER(ticker),
         DATE(date),
         CAST(COALESCE(adj_close, close) AS NUMERIC)
  FROM `stage.industrials`

  UNION ALL
  -- Technology
  SELECT 'TECH',
         UPPER(ticker),
         DATE(date),
         CAST(COALESCE(adj_close, close) AS NUMERIC)
  FROM `stage.technology`

  UNION ALL
  -- Utilities
  SELECT 'UTIL',
         UPPER(ticker),
         DATE(date),
         CAST(COALESCE(adj_close, close) AS NUMERIC)
  FROM `stage.utilities`

  -- Optional: if present
  UNION ALL
  SELECT 'OVERALL',
         UPPER(ticker),
         DATE(date),
         CAST(COALESCE(adj_close, close) AS NUMERIC)
  FROM `stage.overall`
)
SELECT ticker, sector, ds, adj_close
FROM unioned
WHERE ticker IS NOT NULL AND sector IS NOT NULL AND ds IS NOT NULL AND adj_close IS NOT NULL;

-- 2) Compute 5D forward returns per ticker
CREATE OR REPLACE TABLE `labels.forward_ret_5d`
PARTITION BY ds
CLUSTER BY ticker AS
WITH p AS (
  SELECT
    ticker, sector, ds, adj_close,
    LEAD(adj_close, 5) OVER (PARTITION BY ticker ORDER BY ds) AS adj_close_fwd5
  FROM `labels.prices_norm`
),
ret AS (
  SELECT
    ticker, sector, ds,
    SAFE_DIVIDE(adj_close_fwd5 - adj_close, adj_close) AS ret_5d
  FROM p
  WHERE adj_close IS NOT NULL AND adj_close_fwd5 IS NOT NULL
),
-- Sector baseline: same-day median 5D return for that sector
sector_baseline AS (
  SELECT
    sector, ds,
    APPROX_QUANTILES(ret_5d, 100)[OFFSET(50)] AS sector_ret_5d_median
  FROM ret
  GROUP BY sector, ds
)
SELECT
  r.ticker,
  r.ds,
  r.ret_5d,
  -- keep this column name for back-compat (used to be spy_ret_5d)
  sb.sector_ret_5d_median AS spy_ret_5d,
  CAST(r.ret_5d - sb.sector_ret_5d_median AS FLOAT64) AS excess_ret_5d
FROM ret r
JOIN sector_baseline sb USING (sector, ds);

-- 3) Binary label based on sector-excess > 0
CREATE OR REPLACE TABLE `labels.labels_5d_excess_up`
PARTITION BY ds
CLUSTER BY ticker AS
SELECT
  ticker, ds, excess_ret_5d,
  IF(excess_ret_5d > 0, 1, 0) AS label_up
FROM `labels.forward_ret_5d`;


