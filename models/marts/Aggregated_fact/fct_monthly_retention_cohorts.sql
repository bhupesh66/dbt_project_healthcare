--User engagement retention


{{ config(
    materialized='view'
) }}

WITH cohort_setup AS (
    
    select
        analytics_id, 
        DATE_TRUNC('month', MIN(initial_bmi_date)) AS cohort_month
    from {{ ref('user_initial_bmi') }} group by 1
),


activity AS (
    
    select 
        analytics_id, 
        DATE_TRUNC('month',last_measurement_date_in_week) AS activity_month,
        avg(current_weight) as avg_weight

    from {{ ref('fact_weight_and_bmi_progress') }} group by 1,2
  
),

cohort_counts AS (
  
    select
        c.cohort_month,
        DATEDIFF('month', c.cohort_month, a.activity_month) AS month_number,
        ROUND(AVG(avg_weight), 1) AS avg_weight,
        COUNT(DISTINCT a.analytics_id) AS active_customers
    from cohort_setup c
    join activity a ON c.analytics_id = a.analytics_id
    group by 1, 2
)
,
cohort_sizes AS (
    -- Total users in Month 0 for each cohort
    select 
        cohort_month,
        COUNT(DISTINCT analytics_id) AS cohort_size
    from cohort_setup
    group by cohort_month
)

select 
    cc.cohort_month,
    cc.month_number,
    cc.active_customers,
    ROUND(cc.active_customers * 100.0 / cs.cohort_size, 1) as retention_rate,
    avg_weight
from  cohort_counts cc join cohort_sizes cs on cc.cohort_month = cs.cohort_month
order by  cc.cohort_month, cc.month_number