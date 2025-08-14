-- Standard SQL
-- Stage table (native) with partitioning + clustering + normalization
CREATE OR REPLACE TABLE `stage.house_trades`
PARTITION BY transaction_date
CLUSTER BY ticker, entity_name AS
WITH src AS (
  SELECT
    'NDJSON.SOURCE' AS source,
    UPPER(CAST(Ticker AS STRING)) AS ticker,
    CAST(Representative AS STRING) AS entity_name,
    CAST(BioGuideID AS STRING) AS bioguide_id,
    CAST(Transaction AS STRING) AS raw_action,
    CAST(`Range` AS STRING) AS raw_range,
    SAFE_CAST(Amount AS NUMERIC) AS amount_reported,
    SAFE.PARSE_DATE('%Y-%m-%d', CAST(Date AS STRING)) AS transaction_date,
    SAFE.PARSE_DATE('%Y-%m-%d', CAST(last_modified AS STRING)) AS last_modified_date
  FROM `NDJSON.SOURCE`
),
norm AS (
  SELECT
    *,
    CASE
      WHEN LOWER(raw_action) LIKE '%purchase%' THEN  1
      WHEN LOWER(raw_action) LIKE '%sale%'     THEN -1
      ELSE 0
    END AS action_side,
    SAFE_CAST(REPLACE(REGEXP_EXTRACT(raw_range, r'\$?([\d,]+)'), ',', '') AS NUMERIC) AS amount_low,
    SAFE_CAST(REPLACE(REGEXP_EXTRACT(raw_range, r'-\s*\$?([\d,]+)'), ',', '') AS NUMERIC) AS amount_high
  FROM src
),
final AS (
  SELECT
    source, ticker, entity_name, bioguide_id,
    raw_action, action_side, raw_range,
    amount_low, amount_high,
    IFNULL((amount_low + amount_high)/2, amount_reported) AS amount_mid,
    amount_reported,
    transaction_date, last_modified_date,
    TO_HEX(MD5(CONCAT(
      IFNULL(bioguide_id,''),'|',IFNULL(ticker,''),'|',IFNULL(CAST(transaction_date AS STRING),''),'|',
      IFNULL(raw_action,''),'|',IFNULL(raw_range,'')
    ))) AS dedup_hash
  FROM norm
)
SELECT * EXCEPT(rn)
FROM (
  SELECT f.*, ROW_NUMBER() OVER (
    PARTITION BY dedup_hash ORDER BY last_modified_date DESC, transaction_date DESC
  ) AS rn
  FROM final f
)
WHERE rn = 1;
