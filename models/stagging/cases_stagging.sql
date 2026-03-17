--deduplicate to one row per case

{{ config(materialized='view') }}

WITH raw_cases AS (
    SELECT DISTINCT * FROM ASSIGNMENT_YZN.RAW.CASES
)

SELECT
       id AS case_id,
        userAnalyticsId AS analytics_id,
        platform,
        problem AS case_problem_type,
        status AS case_status,
        -- since snowflake is creating problem to parse utc keyword
        TRY_TO_TIMESTAMP_NTZ(REPLACE(created,' UTC', '')) AS created_at,
        TRY_TO_TIMESTAMP_NTZ(REPLACE(updated, ' UTC', '')) AS updated_at,
         visible AS is_visible
FROM raw_cases