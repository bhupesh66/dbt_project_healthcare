-- This model implements SCD Type 2 logic to track user history.
-- Each row represents a specific version of a user's data.
-- VALID_FROM: The date this specific record became active.
-- VALID_TO: The date this record was replaced by a newer version (NULL means current)
----used incremental and bulk loading
{{ config(
    materialized='incremental',
    unique_key='user_version_id',
    incremental_strategy='merge'
) }}

WITH source_data AS (
    select 
        analytics_id,status,
        gender,
        created_at, 
        updated_at AS valid_from
    from {{ ref('users_stagging') }}
),


{% if is_incremental() %}
users_to_update AS (
    select distinct analytics_id
    from source_data
     WHERE valid_from > (SELECT MAX(valid_from) FROM {{ this }})
    )
,
{% endif %}

versioning AS ( 
    select 
        s.analytics_id,
        s.status,
        s.gender,
        s.created_at, 
        s.valid_from,
        ROW_NUMBER() over (
            partition by s.analytics_id 
            order by  s.valid_from ASC
        ) AS version_number,
        LEAD(s.valid_from) over (
            partition by s.analytics_id 
            order by  s.valid_from ASC
        ) AS valid_to
    from source_data s
    
    {% if is_incremental() %}
    INNER JOIN users_to_update u on s.analytics_id = u.analytics_id
    {% endif %}
)

select 
    MD5(CONCAT(analytics_id, CAST(version_number as STRING))) as user_version_id,--surrogate key
    analytics_id,
    version_number,
    status,
    gender,
    created_at, 
    valid_from,
    COALESCE(valid_to, '9999-12-31'::timestamp_ntz) as valid_to,--open end date represent current version
    case when valid_to IS NULL then TRUE else FALSE end as is_current
from versioning