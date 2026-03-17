
--This is gender-Based BMI Category Migration: Monthly Cohort Progress we can do weekly yearly too.

{{ config(
    materialized='table'
) }}

WITH source AS (
    select 
        u.gender, FLOOR(f.week_number / 4) AS program_month,
        f.bmi_category
    from {{ ref('fact_weight_and_bmi_progress') }} f
    join {{ ref('dim_user') }} u on f.analytics_id = u.analytics_id
)

select
    gender,
    program_month,
    ROUND(100 * COUNT(CASE WHEN bmi_category = 'Obese Class II' THEN 1 END) / COUNT(*), 1) AS obese_ii_percentage,
    ROUND(100 * COUNT(CASE WHEN bmi_category = 'Obese Class I' THEN 1 END) / COUNT(*), 1) AS obese_i_percentage,
    ROUND(100 * COUNT(CASE WHEN bmi_category = 'Overweight' THEN 1 END) / COUNT(*), 1) AS overweight_percentage,
    ROUND(100 * COUNT(CASE WHEN bmi_category = 'Healthy Range' THEN 1 END) / COUNT(*), 1) AS healthy_percentage,
    ROUND(100 * COUNT(CASE WHEN bmi_category = 'underweight' THEN 1 END) / COUNT(*), 1) AS underweight_percentage,
    COUNT(*) as total_sample_size
from source
group by  1, 2
order by  2, 1