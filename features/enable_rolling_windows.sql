CREATE OR REPLACE TABLE `feature.signals_daily_base`
PARTITION BY ds
CLUSTER BY ticker AS
WITH cal AS (
  SELECT ds, ticker FROM `feature.calendar_by_ticker`
),
j AS (
  SELECT
    c.ticker, c.ds,
    cd.congress_net_usd, cd.congress_gross_usd, cd.congress_buy_usd, cd.congress_sell_usd,
    cd.congress_buy_cnt, cd.congress_sell_cnt,
    sd.senate_net_usd, sd.senate_gross_usd, sd.senate_buy_usd, sd.senate_sell_usd,
    sd.senate_buy_cnt, sd.senate_sell_cnt,
    ld.lobbying_usd, ld.lobbying_events, ld.lobbying_issue_diversity,
    od.dpi, od.short_ratio
  FROM cal c
  LEFT JOIN `feature.congress_daily` cd USING (ticker, ds)
  LEFT JOIN `feature.senate_daily`   sd USING (ticker, ds)
  LEFT JOIN `feature.lobby_daily` ld USING (ticker, ds)
  LEFT JOIN `feature.darkpool_daily`    od USING (ticker, ds)
)
SELECT
  ticker, ds,
  -- Zero-fill missing numeric signals (safer for rolling sums)
  COALESCE(congress_net_usd,0)           AS congress_net_usd,
  COALESCE(congress_gross_usd,0)         AS congress_gross_usd,
  COALESCE(congress_buy_usd,0)           AS congress_buy_usd,
  COALESCE(congress_sell_usd,0)          AS congress_sell_usd,
  COALESCE(congress_buy_cnt,0)           AS congress_buy_cnt,
  COALESCE(congress_sell_cnt,0)          AS congress_sell_cnt,

  COALESCE(senate_net_usd,0)             AS senate_net_usd,
  COALESCE(senate_gross_usd,0)           AS senate_gross_usd,
  COALESCE(senate_buy_usd,0)             AS senate_buy_usd,
  COALESCE(senate_sell_usd,0)            AS senate_sell_usd,
  COALESCE(senate_buy_cnt,0)             AS senate_buy_cnt,
  COALESCE(senate_sell_cnt,0)            AS senate_sell_cnt,

  COALESCE(lobbying_usd,0)               AS lobbying_usd,
  COALESCE(lobbying_events,0)            AS lobbying_events,
  COALESCE(lobbying_issue_diversity,0)   AS lobbying_issue_diversity,

  COALESCE(dpi,NULL)                     AS dpi,
  COALESCE(short_ratio,NULL)             AS short_ratio
FROM j;
