-- Congress daily
CREATE OR REPLACE TABLE `feature.congress_daily`
PARTITION BY ds
CLUSTER BY ticker AS
SELECT
  ct.ticker,
  ct.transaction_date AS ds,
  SUM(COALESCE(ct.amount_mid,0) * ct.action_side)             AS congress_net_usd,
  SUM(COALESCE(ct.amount_mid,0))                               AS congress_gross_usd,
  SUM(IF(ct.action_side= 1, COALESCE(ct.amount_mid,0), 0))     AS congress_buy_usd,
  SUM(IF(ct.action_side=-1, COALESCE(ct.amount_mid,0), 0))     AS congress_sell_usd,
  COUNTIF(ct.action_side= 1)                                   AS congress_buy_cnt,
  COUNTIF(ct.action_side=-1)                                   AS congress_sell_cnt
FROM `stage.congress` ct
GROUP BY 1,2;

-- Senate daily
CREATE OR REPLACE TABLE `feature.senate_daily`
PARTITION BY ds
CLUSTER BY ticker AS
SELECT
  st.ticker,
  st.transaction_date AS ds,
  SUM(COALESCE(st.amount_mid,0) * st.action_side)             AS senate_net_usd,
  SUM(COALESCE(st.amount_mid,0))                               AS senate_gross_usd,
  SUM(IF(st.action_side= 1, COALESCE(st.amount_mid,0), 0))     AS senate_buy_usd,
  SUM(IF(st.action_side=-1, COALESCE(st.amount_mid,0), 0))     AS senate_sell_usd,
  COUNTIF(st.action_side= 1)                                   AS senate_buy_cnt,
  COUNTIF(st.action_side=-1)                                   AS senate_sell_cnt
FROM `stage.senate` st
GROUP BY 1,2;

-- Lobbying daily (sum amounts; also build issue richness)
CREATE OR REPLACE TABLE `feature.lobby_daily`
PARTITION BY ds
CLUSTER BY ticker AS
SELECT
  le.ticker,
  le.event_date AS ds,
  SUM(COALESCE(le.amount_usd,0)) AS lobbying_usd,
  COUNT(*)                        AS lobbying_events,
  COUNT(DISTINCT le.issue)        AS lobbying_issue_diversity
FROM `stage.lobbying` le
GROUP BY 1,2;

-- Off-exchange daily
CREATE OR REPLACE TABLE `feature.darkpool_daily`
PARTITION BY ds
CLUSTER BY ticker AS
SELECT
  oe.ticker,
  oe.trade_date AS ds,
  AVG(oe.dpi)        AS dpi,          -- already daily; AVG is idempotent if duplicates exist
  AVG(oe.short_ratio) AS short_ratio
FROM `stage.offexchange` oe
GROUP BY 1,2;
