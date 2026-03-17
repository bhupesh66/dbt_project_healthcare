--Weekly Weight Loss Analysis.We can also calculate Year-Over-Year (YoY) Cohort Analysis if needed.

{{ config(
    materialized='table'
) }}

select 
    week_number,ROUND(AVG(weight_change_kg), 2) AS avg_weight_change_kg,
    
    COUNT(DISTINCT analytics_id) AS active_user_count
from {{ ref('fact_weight_and_bmi_progress') }}
group by 1
order by  1