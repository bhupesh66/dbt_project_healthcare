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
,
cohort_sizes AS (
    -- Total users in Month 0 for each cohort
    SELECT
        cohort_month,
        COUNT(DISTINCT analytics_id) AS cohort_size
    FROM cohort_setup
    GROUP BY cohort_month
)

SELECT
    cc.cohort_month,
    cc.month_number,
    cc.active_customers,
    ROUND(cc.active_customers * 100.0 / cs.cohort_size, 1) AS retention_rate
FROM cohort_counts cc
JOIN cohort_sizes cs
    ON cc.cohort_month = cs.cohort_month
ORDER BY cc.cohort_month, cc.month_number