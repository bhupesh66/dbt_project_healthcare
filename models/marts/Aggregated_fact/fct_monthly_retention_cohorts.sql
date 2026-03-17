--User Retention Lifecycle


{{ config(
    materialized='table'
) }}

WITH cohort_setup AS (
    -- Get the "Birth Month" for every user
    SELECT 
        analytics_id, 
        DATE_TRUNC('month', MIN(initial_bmi_date)) AS cohort_month
    FROM {{ ref('user_initial_bmi') }}
    GROUP BY 1
),

activity AS (
    -- Get every month where a user was active
    SELECT DISTINCT 
        analytics_id, 
        DATE_TRUNC('month', measured_at) AS activity_month
    FROM {{ ref('measurements_stagging') }}
    WHERE measurement_type = 'weight'
),

cohort_counts AS (
    -- Join activity back to the "Birth Month"
    SELECT
        c.cohort_month,
        DATEDIFF('month', c.cohort_month, a.activity_month) AS month_number,
        COUNT(DISTINCT a.analytics_id) AS active_customers
    FROM cohort_setup c
    JOIN activity a ON c.analytics_id = a.analytics_id
    GROUP BY 1, 2
)

SELECT
    cohort_month,
    month_number,
    active_customers,
    -- Window function gets the size of Month 0 for each cohort to calculate the rate
    ROUND(active_customers * 100.0 / 
        MAX(active_customers) OVER (PARTITION BY cohort_month), 1) AS retention_rate
FROM cohort_counts
ORDER BY cohort_month, month_number