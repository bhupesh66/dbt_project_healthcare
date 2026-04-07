--Weekly Weight Loss Analysis.We can also calculate Year-Over-Year (YoY) Cohort Analysis if needed.

{{ config(
    materialized='table'
) }}

select 
    week_number,ROUND(AVG(cummulatives_weight_change), 2) AS avg_weight_change_kg_cummulative,
    ROUND(AVG(delta_incremental_change), 2) AS avg_weight_change_kg_incremental,
    COUNT(DISTINCT analytics_id) AS active_user_count
from {{ ref('fact_weight_and_bmi_progress') }}
group by 1
order by  1