--deduplicate to one row per case

{{ config(materialized='view') }}

with raw_cases AS (
    select distinct * from  ASSIGNMENT_YZN.RAW.CASES
)

select
       id AS case_id,
        userAnalyticsId AS analytics_id,
        platform,
        problem ,
        status AS case_status,
        -- since snowflake is creating problem to parse utc keyword
        TRY_TO_TIMESTAMP_NTZ(REPLACE(created,' UTC', '')) AS created_at,
        TRY_TO_TIMESTAMP_NTZ(REPLACE(updated, ' UTC', '')) AS updated_at,
         visible 
from raw_cases