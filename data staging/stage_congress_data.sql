-- Standard SQL
CREATE OR REPLACE TABLE `stage.congress`
PARTITION BY transaction_date
CLUSTER BY ticker, entity_name AS
WITH src AS (
  SELECT
    'NDJSON.SOURCE' AS source,
    UPPER(CAST(Ticker AS STRING)) AS ticker,
    CAST(TickerType AS STRING) AS ticker_type,
    CAST(Representative AS STRING) AS entity_name,
    CAST(BioGuideID AS STRING) AS bioguide_id,
    CAST(House AS STRING) AS chamber,
    CAST(Party AS STRING) AS party,
    CAST(Transaction AS STRING) AS raw_action,
    CAST(`Range` AS STRING) AS raw_range,
    SAFE_CAST(Amount AS NUMERIC) AS amount_reported,
    SAFE.PARSE_DATE('%Y-%m-%d', CAST(TransactionDate AS STRING)) AS transaction_date,
    SAFE.PARSE_DATE('%Y-%m-%d', CAST(ReportDate AS STRING)) AS report_date,
    SAFE_CAST(PriceChange AS FLOAT64) AS price_change,
    SAFE_CAST(SPYChange AS FLOAT64) AS spy_change,
    SAFE_CAST(ExcessReturn AS FLOAT64) AS excess_return,
    CAST(Description AS STRING) AS description
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
    source, ticker, ticker_type, entity_name, bioguide_id, chamber, party,
    raw_action, action_side, raw_range,
    amount_low,
    amount_high,
    IFNULL((amount_low + amount_high)/2, amount_reported) AS amount_mid,
    amount_reported,
    transaction_date,
    report_date,
    price_change, spy_change, excess_return,
    description,
    TO_HEX(MD5(CONCAT(
      IFNULL(bioguide_id,''),'|',IFNULL(ticker,''),'|',IFNULL(CAST(transaction_date AS STRING),''),'|',
      IFNULL(raw_action,''),'|',IFNULL(raw_range,'')
    ))) AS dedup_hash
  FROM norm
)
SELECT * EXCEPT(rn)
FROM (
  SELECT f.*, ROW_NUMBER() OVER (
    PARTITION BY dedup_hash ORDER BY report_date DESC, transaction_date DESC
  ) AS rn
  FROM final f
)
WHERE rn = 1;
