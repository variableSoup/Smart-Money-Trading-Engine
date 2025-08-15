-- Inputs: @top_n INT64
WITH base AS (
  SELECT UPPER(ticker) AS ticker, trade_date, dpi, short_ratio
  FROM `stage.offexchange`
  WHERE trade_date >= DATE '2024-01-01'
),
win AS (
  SELECT
    ticker, trade_date, dpi, short_ratio,
    AVG(dpi)        OVER (PARTITION BY ticker ORDER BY trade_date ROWS BETWEEN 20 PRECEDING AND CURRENT ROW) AS dpi_ma21,
    STDDEV_SAMP(dpi)OVER (PARTITION BY ticker ORDER BY trade_date ROWS BETWEEN 62 PRECEDING AND CURRENT ROW) AS dpi_sd63,
    AVG(short_ratio)        OVER (PARTITION BY ticker ORDER BY trade_date ROWS BETWEEN 20 PRECEDING AND CURRENT ROW) AS sr_ma21,
    STDDEV_SAMP(short_ratio)OVER (PARTITION BY ticker ORDER BY trade_date ROWS BETWEEN 62 PRECEDING AND CURRENT ROW) AS sr_sd63
  FROM base
),
scored AS (
  SELECT
    ticker, trade_date, dpi, short_ratio,
    SAFE_DIVIDE(dpi - dpi_ma21, NULLIF(dpi_sd63,0)) AS dpi_z_63,
    SAFE_DIVIDE(short_ratio - sr_ma21, NULLIF(sr_sd63,0)) AS short_ratio_z_63
  FROM win
),
best_dpi AS (
  SELECT * EXCEPT(rn) FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY dpi_z_63 DESC) AS rn
    FROM scored
    WHERE dpi_z_63 IS NOT NULL
  ) WHERE rn = 1
),
best_short AS (
  SELECT * EXCEPT(rn) FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY short_ratio DESC) AS rn
    FROM scored
    WHERE short_ratio IS NOT NULL
  ) WHERE rn = 1
),
top_dpi AS (
  SELECT ARRAY_TO_STRING(ARRAY(
    SELECT FORMAT('%s (z=%.2f on %s, dpi=%.3f)', ticker, dpi_z_63, CAST(trade_date AS STRING), dpi)
    FROM best_dpi
    ORDER BY dpi_z_63 DESC
    LIMIT @top_n
  ), ', ') AS txt
),
top_short AS (
  SELECT ARRAY_TO_STRING(ARRAY(
    SELECT FORMAT('%s (sr=%.3f on %s)', ticker, short_ratio, CAST(trade_date AS STRING))
    FROM best_short
    ORDER BY short_ratio DESC
    LIMIT @top_n
  ), ', ') AS txt
)
SELECT
  CURRENT_DATE() AS trade_date,
  (SELECT txt FROM top_dpi)   AS top_dpi_list,
  (SELECT txt FROM top_short) AS top_short_list;
