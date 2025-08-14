CREATE OR REPLACE MODEL `models.quiver_sentiment_lr_v1`
OPTIONS (
  model_type = 'logistic_reg',
  input_label_cols = ['label_up'],
  auto_class_weights = TRUE,
  l2_reg = 0.1,
  learn_rate_strategy = 'line_search',
  max_iterations = 50,
  data_split_col = 'is_train',
  data_split_method = 'CUSTOM'
) AS
SELECT
  -- Quiver features (as-is)
  congress_net_usd_7d, congress_net_usd_21d, congress_net_usd_63d,
  congress_buy_cnt_21d, congress_sell_cnt_21d,
  senate_net_usd_7d, senate_net_usd_21d, senate_net_usd_63d,
  senate_buy_cnt_21d, senate_sell_cnt_21d,
  lobbying_usd_63d, lobbying_events_63d, lobbying_issue_diversity_63d,

  -- Off-exchange: fill NULLs so BQML can compute stats
  COALESCE(dpi_last, 0)          AS dpi_last,
  COALESCE(dpi_ma21, 0)          AS dpi_ma21,
  COALESCE(dpi_z_63, 0)          AS dpi_z_63,
  COALESCE(short_ratio_last, 0)  AS short_ratio_last,
  COALESCE(short_ratio_ma21, 0)  AS short_ratio_ma21,
  COALESCE(short_ratio_z_63, 0)  AS short_ratio_z_63,

  label_up, is_train
FROM `train.quiver_sentiment_train_v1`
WHERE label_up IS NOT NULL;
