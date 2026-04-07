{{ config(
    materialized='table'
) }}

WITH unique_users AS (
    SELECT DISTINCT 
        analytics_id, 
        gender
    FROM {{ ref('dim_user') }} where is_deleted=FALSE
),

monthly_logs AS (
    SELECT 
        u.gender,
        FLOOR(f.week_number / 4) AS in_month,
        f.bmi_category,
        f.analytics_id
    FROM {{ ref('fact_weight_and_bmi_progress') }} f
    JOIN unique_users u ON f.analytics_id = u.analytics_id

    -- QUALIFY ROW_NUMBER() OVER (
    --     PARTITION BY f.analytics_id, FLOOR(f.week_number / 4) 
    --     ORDER BY f.week_number DESC
    -- ) = 1
)

SELECT
    gender,
    in_month,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN bmi_category = 'Obese Class II' THEN analytics_id END) 
        / NULLIF(COUNT(DISTINCT analytics_id), 0), 2) AS obese_ii_percentage,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN bmi_category = 'Obese Class I' THEN analytics_id END) 
        / NULLIF(COUNT(DISTINCT analytics_id), 0), 2) AS obese_i_percentage,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN bmi_category = 'Overweight' THEN analytics_id END) 
        / NULLIF(COUNT(DISTINCT analytics_id), 0), 2) AS overweight_percentage,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN bmi_category = 'Healthy Range' THEN analytics_id END) 
        / NULLIF(COUNT(DISTINCT analytics_id), 0), 2) AS healthy_percentge,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN bmi_category = 'underweight' THEN analytics_id END) 
        / NULLIF(COUNT(DISTINCT analytics_id), 0), 2) AS underweight_percentage,
    COUNT(DISTINCT analytics_id) AS unique_user_count
FROM monthly_logs
GROUP BY 1, 2

ORDER BY 2, 1