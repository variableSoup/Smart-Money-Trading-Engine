CREATE OR REPLACE TABLE `feature.calendar_by_ticker`
PARTITION BY ds
CLUSTER BY ticker AS
WITH all_dates AS (
  SELECT DISTINCT trade_date AS ds, ticker
  FROM `stage.offexchange`
  UNION DISTINCT
  SELECT DISTINCT transaction_date AS ds, ticker
  FROM `stage.congress`
  UNION DISTINCT
  SELECT DISTINCT transaction_date AS ds, ticker
  FROM `stage.senate`
  UNION DISTINCT
  SELECT DISTINCT event_date AS ds, ticker
  FROM `stage.lobbying`
  UNION DISTINCT
  SELECT DISTINCT date AS ds, ticker
  FROM `stage.communcations`
  UNION DISTINCT
  SELECT DISTINCT date AS ds, ticker
  FROM `stage.consumerDiscretion`
  UNION DISTINCT
  SELECT DISTINCT date AS ds, ticker
  FROM `stage.consumerStaples`
  UNION DISTINCT
  SELECT DISTINCT date AS ds, ticker
  FROM `stage.energy`
  UNION DISTINCT
  SELECT DISTINCT date AS ds, ticker
  FROM `stage.financial`
  UNION DISTINCT
  SELECT DISTINCT date AS ds, ticker
  FROM `stage.healthcare`
  UNION DISTINCT
  SELECT DISTINCT date AS ds, ticker
  FROM `stage.industrials`
  UNION DISTINCT
  SELECT DISTINCT date AS ds, ticker
  FROM `stage.overall`
  UNION DISTINCT
  SELECT DISTINCT date AS ds, ticker
  FROM `stage.technology`
  UNION DISTINCT
  SELECT DISTINCT date AS ds, ticker
  FROM `stage.utilities`
),
clean AS (
  SELECT ds, ticker
  FROM all_dates
  WHERE ds IS NOT NULL AND ticker IS NOT NULL
)
SELECT ds, ticker FROM clean;

