--Overall User Health Transformation: Monthly Success Milestones

{{ config(
    materialized='table'
) }}

with base_data AS (
   select
        f.analytics_id,
        FLOOR(f.week_number / 4) AS program_month,
        f.weight_change_kg,
        f.initial_weight,
        f.bmi_category,FIRST_VALUE(f.bmi_category) OVER (
            PARTITION BY f.analytics_id 
            ORDER BY f.week_number ASC
        ) AS starting_bmi_category
    from {{ ref('fact_weight_and_bmi_progress') }} f
),

success_flags AS (
    select 
        *, case
            when  bmi_category = 'Healthy Range' AND starting_bmi_category IN ('Overweight', 'Obese Class I', 'Obese Class II') THEN 1
            when bmi_category = 'Overweight' AND starting_bmi_category IN ('Obese Class I', 'Obese Class II') THEN 1
            when bmi_category = 'Obese Class I' AND starting_bmi_category = 'Obese Class II' THEN 1
            else 0 
        end as  has_improved_category
    from  base_data
)

select 
    program_month,
    ROUND(100 * SUM(has_improved_category) / COUNT(*), 1) AS improvement_percentage,
    ROUND(AVG(ABS(weight_change_kg)), 2) AS avg_kg_lost,
    COUNT(DISTINCT analytics_id) AS active_user_count
from  success_flags
group by  1 order by 1