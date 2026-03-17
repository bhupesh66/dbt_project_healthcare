{{ config(
    materialized='incremental',
    unique_key='user_version_id',
    incremental_strategy='merge'
) }}

WITH source_data AS (
    SELECT 
        analytics_id,
        status,
        gender,
        created_at, 
        updated_at AS valid_from
    FROM {{ ref('users_stagging') }}
),

{% if is_incremental() %}
users_to_update AS (
    SELECT DISTINCT analytics_id
    FROM source_data
    WHERE valid_from > (
        SELECT 
            DATEADD(day, -30, CAST(MAX(valid_from) AS TIMESTAMP_NTZ))
        FROM {{ this }}
    )
),
{% endif %}

versioning AS ( 
    SELECT 
        s.analytics_id,
        s.status,
        s.gender,
        s.created_at, -- Carry it through
        s.valid_from,
        ROW_NUMBER() OVER (
            PARTITION BY s.analytics_id 
            ORDER BY s.valid_from ASC
        ) AS version_number,
        LEAD(s.valid_from) OVER (
            PARTITION BY s.analytics_id 
            ORDER BY s.valid_from ASC
        ) AS valid_to
    FROM source_data s
    
    {% if is_incremental() %}
    INNER JOIN users_to_update u ON s.analytics_id = u.analytics_id
    {% endif %}
)

SELECT
    MD5(CONCAT(analytics_id, CAST(version_number AS STRING))) AS user_version_id,
    analytics_id,
    version_number,
    status,
    gender,
    created_at, 
    valid_from,
    COALESCE(valid_to, '9999-12-31'::timestamp_ntz) AS valid_to,
    CASE WHEN valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current
FROM versioning