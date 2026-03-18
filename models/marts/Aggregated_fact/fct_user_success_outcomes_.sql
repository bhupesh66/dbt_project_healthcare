--Overall User Health Transformation: Monthly Success Milestones

{{ config(
    materialized='table'
) }}

with base_data_initial AS (
   select
        f.analytics_id,
        FLOOR(f.week_number / 4) AS program_month,
        f.weight_change_kg,
        f.initial_weight,
        f.bmi_category,
        
     
        ROW_NUMBER() OVER (
            PARTITION BY f.analytics_id 
            ORDER BY f.week_number ASC
        ) AS starting_bmi_category
    from {{ ref('fact_weight_and_bmi_progress') }} f
    
),

base_data as (
select * from base_data where starting_bmi_category=1
),

success_flags AS (
    select 
        *,
        case
            when bmi_category = 'Healthy Range' AND starting_bmi_category IN ('Overweight', 'Obese Class I', 'Obese Class II') THEN 1
            when bmi_category = 'Overweight' AND starting_bmi_category IN ('Obese Class I', 'Obese Class II') THEN 1
            when bmi_category = 'Obese Class I' AND starting_bmi_category = 'Obese Class II' THEN 1
            else 0 
        end as  has_improved_category
    from  base_data
)

SELECT
    program_month,
    ROUND(100 * SUM(has_improved_category) / COUNT(*), 1) AS pct_category_improvement,
    ROUND(AVG(ABS(weight_change_kg)), 2) AS avg_kg_lost,
    COUNT(DISTINCT analytics_id) AS active_user_count
FROM success_flags
GROUP BY 1
ORDER BY 1