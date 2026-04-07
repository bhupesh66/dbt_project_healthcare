--deduplicate, chnage columns names, typecasting column type and selecting only visible = true


{{ config(materialized='view') }}

WITH raw_measurements AS 
(
    
        select  *,ROW_NUMBER() OVER (
            PARTITION BY id 
            ORDER BY updated DESC
        ) as version_rank from  ASSIGNMENT_YZN.RAW.MEASUREMENTS
)

select
    id as  measurement_id,
    userAnalyticsId as analytics_id,
    type as  measurement_type,
    unit,
    updated,
    value  AS measurement_value,
      -- since snowflake is creating problem to parse utc keyword
    TRY_TO_TIMESTAMP(REPLACE(measured, ' UTC', '')) AS measured_at,
    visible 
from raw_measurements
where version_rank = 1 



