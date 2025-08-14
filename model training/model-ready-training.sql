CREATE OR REPLACE TABLE `train.quiver_sentiment_train_v1`
PARTITION BY ds
CLUSTER BY ticker AS
WITH f AS (
  SELECT * FROM `feature.signals_features_v1`
),
y AS (
  SELECT * FROM `labels.labels_5d_excess_up`
),
j AS (
  SELECT
    f.ticker, f.ds,
    -- Features
    congress_net_usd_7d, congress_net_usd_21d, congress_net_usd_63d,
    congress_buy_cnt_21d, congress_sell_cnt_21d,
    senate_net_usd_7d, senate_net_usd_21d, senate_net_usd_63d,
    senate_buy_cnt_21d, senate_sell_cnt_21d,
    lobbying_usd_63d, lobbying_events_63d, lobbying_issue_diversity_63d,
    dpi_last, dpi_ma21, dpi_z_63,
    short_ratio_last, short_ratio_ma21, short_ratio_z_63,
    -- Label
    y.excess_ret_5d, y.label_up
  FROM f
  INNER JOIN y USING (ticker, ds)
)
SELECT
  j.*,
  -- Time-aware hash split: ~80% train, 20% eval
  IF(MOD(ABS(FARM_FINGERPRINT(CONCAT(j.ticker, CAST(j.ds AS STRING)))), 10) < 8, TRUE, FALSE) AS is_train
FROM j;
