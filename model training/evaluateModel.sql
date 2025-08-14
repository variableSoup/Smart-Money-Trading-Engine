-- Overall metrics on the holdout split
SELECT *
FROM ML.EVALUATE(
  MODEL `models.quiver_sentiment_lr_v1`,
  (
    SELECT
      congress_net_usd_7d, congress_net_usd_21d, congress_net_usd_63d,
      congress_buy_cnt_21d, congress_sell_cnt_21d,
      senate_net_usd_7d, senate_net_usd_21d, senate_net_usd_63d,
      senate_buy_cnt_21d, senate_sell_cnt_21d,
      lobbying_usd_63d, lobbying_events_63d, lobbying_issue_diversity_63d,
      COALESCE(dpi_last,0)         AS dpi_last,
      COALESCE(dpi_ma21,0)         AS dpi_ma21,
      COALESCE(dpi_z_63,0)         AS dpi_z_63,
      COALESCE(short_ratio_last,0) AS short_ratio_last,
      COALESCE(short_ratio_ma21,0) AS short_ratio_ma21,
      COALESCE(short_ratio_z_63,0) AS short_ratio_z_63,
      label_up
    FROM `train.quiver_sentiment_train_v1`
    WHERE is_train = FALSE
  )
);

-- ROC curve (holdout) — no 3rd arg
SELECT *
FROM ML.ROC_CURVE(
  MODEL `models.quiver_sentiment_lr_v1`,
  (
    SELECT
      congress_net_usd_7d, congress_net_usd_21d, congress_net_usd_63d,
      congress_buy_cnt_21d, congress_sell_cnt_21d,
      senate_net_usd_7d, senate_net_usd_21d, senate_net_usd_63d,
      senate_buy_cnt_21d, senate_sell_cnt_21d,
      lobbying_usd_63d, lobbying_events_63d, lobbying_issue_diversity_63d,
      COALESCE(dpi_last,0)         AS dpi_last,
      COALESCE(dpi_ma21,0)         AS dpi_ma21,
      COALESCE(dpi_z_63,0)         AS dpi_z_63,
      COALESCE(short_ratio_last,0) AS short_ratio_last,
      COALESCE(short_ratio_ma21,0) AS short_ratio_ma21,
      COALESCE(short_ratio_z_63,0) AS short_ratio_z_63,
      label_up
    FROM `train.quiver_sentiment_train_v1`
    WHERE is_train = FALSE
  )
);

-- Confusion matrix at 0.5 threshold (holdout) — 3rd arg IS allowed here
SELECT *
FROM ML.CONFUSION_MATRIX(
  MODEL `models.quiver_sentiment_lr_v1`,
  (
    SELECT
      congress_net_usd_7d, congress_net_usd_21d, congress_net_usd_63d,
      congress_buy_cnt_21d, congress_sell_cnt_21d,
      senate_net_usd_7d, senate_net_usd_21d, senate_net_usd_63d,
      senate_buy_cnt_21d, senate_sell_cnt_21d,
      lobbying_usd_63d, lobbying_events_63d, lobbying_issue_diversity_63d,
      COALESCE(dpi_last,0)         AS dpi_last,
      COALESCE(dpi_ma21,0)         AS dpi_ma21,
      COALESCE(dpi_z_63,0)         AS dpi_z_63,
      COALESCE(short_ratio_last,0) AS short_ratio_last,
      COALESCE(short_ratio_ma21,0) AS short_ratio_ma21,
      COALESCE(short_ratio_z_63,0) AS short_ratio_z_63,
      label_up
    FROM `train.quiver_sentiment_train_v1`
    WHERE is_train = FALSE
  ),
  STRUCT(0.5 AS threshold)
);
