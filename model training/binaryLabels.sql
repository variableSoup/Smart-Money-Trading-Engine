CREATE OR REPLACE TABLE `labels.labels_5d_excess_up`
PARTITION BY ds
CLUSTER BY ticker AS
SELECT
  ticker, ds,
  excess_ret_5d,
  IF(excess_ret_5d > 0, 1, 0) AS label_up  -- 1 if beats SPY next 5d
FROM `labels.forward_ret_5d`;
