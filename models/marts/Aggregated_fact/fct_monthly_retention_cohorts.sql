--User Retention Lifecycle


{{ config(
    materialized='table'
) }}

WITH cohort_setup AS (
    
    select
        analytics_id, 
        DATE_TRUNC('month', MIN(initial_bmi_date)) AS cohort_month
    from {{ ref('user_initial_bmi') }} group by 1
),


activity AS (
    
    select distinct 
        analytics_id, 
        DATE_TRUNC('month', measured_at) AS activity_month
    from {{ ref('measurements_stagging') }}
    where measurement_type = 'weight'
),

cohort_counts AS (
  
    select
        c.cohort_month,
        DATEDIFF('month', c.cohort_month, a.activity_month) AS month_number,
        COUNT(DISTINCT a.analytics_id) AS active_customers
    from cohort_setup c
    join activity a ON c.analytics_id = a.analytics_id
    group by 1, 2
)

select
     cohort_month,
    month_number,
    active_customers,ROUND(active_customers * 100.0 / 
        MAX(active_customers) OVER (PARTITION BY cohort_month), 1) AS retention_rate
from cohort_counts
order by  cohort_month, month_number