--deduplicating users table 
-- renaming columns, casting columns

{{ config(materialized='view') }}

WITH raw_users AS (
    
    select distinct * FROM ASSIGNMENT_YZN.RAW.USERS --raw table 
)

select 
    analyticsId AS analytics_id,
    organizationId AS organization_id,
    -- since snowflake is creating problem to parse utc keywoard
    TRY_TO_TIMESTAMP_NTZ(REPLACE(updated, ' UTC', '')) AS updated_at,
    TRY_TO_TIMESTAMP_NTZ(REPLACE(created, ' UTC', '')) AS created_at,
    gender, zipCode AS zip_code,
    cast(birthdate AS DATE) AS birth_date,
    status,
    COALESCE(removed, FALSE) AS is_removed,
    visible AS is_visible
FROM raw_users