--deduplicating users table 
-- renaming columns, casting columns

{{ config(materialized='view') }}

with  raw_users AS (
    
        select distinct * from ASSIGNMENT_YZN.RAW.USERS --raw table 
)

select 
    analyticsId AS analytics_id,
    organizationId,
    -- since snowflake is creating problem to parse utc keywoard
    TRY_TO_TIMESTAMP_NTZ (REPLACE(updated, ' UTC', '')) AS updated_at,

    TRY_TO_TIMESTAMP_NTZ(REPLACE(created, ' UTC', '')) AS created_at,
    gender, zipCode,
    cast(birthdate  as date) as birthdate,
    status,
    COALESCE(removed, FALSE) as is_removed,
    visible 
FROM raw_users  
--where  visible=TRUE


