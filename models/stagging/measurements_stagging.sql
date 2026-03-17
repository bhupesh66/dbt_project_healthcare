--deduplicate, chnage columns names, typecasting column type and selecting only visible = true


{{ config(materialized='view') }}

WITH raw_measurements AS (
    
    SELECT distinct * FROM ASSIGNMENT_YZN.RAW.MEASUREMENTS
)

SELECT
    id as  measurement_id,
    userAnalyticsId as analytics_id,
    type as  measurement_type,
    unit,
    TRY_CAST(value AS FLOAT) AS measurement_value,
      -- since snowflake is creating problem to parse utc keyword
    TRY_TO_TIMESTAMP(REPLACE(measured, ' UTC', '')) AS measured_at,
    visible AS is_visible
FROM raw_measurements
WHERE measurement_value IS NOT NULL and is_visible=TRUE