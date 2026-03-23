--Overall User Health Transformation: Monthly Success Milestones

{{ config(
    materialized='table'
) }}

with base_data AS (
   select
        f.analytics_id,
        FLOOR(f.week_number / 4) AS program_month,
        f.delta_incremental_change,
        f.cummulatives_weight_change,
        f.initial_weight,
        f.bmi_category,FIRST_VALUE(f.bmi_category) OVER (
            PARTITION BY f.analytics_id 
            ORDER BY f.week_number ASC
        ) AS starting_bmi_category,
        lag(f.bmi_category)over(partition by f.analytics_id order by f.week_number) as ld
    from {{ ref('fact_weight_and_bmi_progress') }} f
),

success_flags AS (
    select 
        *, case
            when  bmi_category = 'Healthy Range' AND starting_bmi_category IN ('Overweight', 'Obese Class I', 'Obese Class II') THEN 1
            when bmi_category = 'Overweight' AND starting_bmi_category IN ('Obese Class I', 'Obese Class II') THEN 1
            when bmi_category = 'Obese Class I' AND starting_bmi_category = 'Obese Class II' THEN 1
            else 0 
        end as  has_improved_category,

        case
            when  bmi_category = 'Healthy Range' AND ld IN ('Overweight', 'Obese Class I', 'Obese Class II') THEN 1
            when bmi_category = 'Overweight' AND ld IN ('Obese Class I', 'Obese Class II') THEN 1
            when bmi_category = 'Obese Class I' AND ld = 'Obese Class II' THEN 1
            else 0 
        end as  has_improved_category_delta

    from  base_data
)



select 
    program_month,
    ROUND(100 * SUM(has_improved_category) / COUNT(*), 1) AS improvement_percentage_cummulative,
    ROUND(AVG(ABS(cummulatives_weight_change)), 2) AS avg_kg_lost_cummulative,
    ROUND(100 * SUM(has_improved_category_delta) / COUNT(*), 1) AS improvement_percentage_delta,
    ROUND(AVG(ABS(delta_incremental_change)), 2) AS avg_kg_lost_delta,
    COUNT(DISTINCT analytics_id) AS active_user_count
from  success_flags
group by  1 order by 1