-- User business retention by cohort
{{ config(
    materialized='table'
) }}

WITH cohort_setup AS (
    -- Identify the first month a user became a member
    SELECT
        analytics_id,
        DATE_TRUNC('month', MIN(created_at)) AS cohort_month
    FROM {{ ref('users_stagging') }}
    WHERE status IN ('member', 'alumni')  -- only paying users
    GROUP BY 1
),

monthly_status AS (
    -- Track each user's status per month
    SELECT
        analytics_id,
        DATE_TRUNC('month', updated_at) AS month,
        status
    FROM {{ ref('users_stagging') }}
    WHERE status IN ('member', 'alumni')
),

cohort_retention AS (
    -- Calculate whether user is active in that month
    SELECT
        c.cohort_month,
        ms.analytics_id,
        DATEDIFF('month', c.cohort_month, ms.month) AS month_number,
        MAX(CASE WHEN ms.status = 'member' THEN 1 ELSE 0 END) AS is_active_member
    FROM cohort_setup c
    LEFT JOIN monthly_status ms
        ON c.analytics_id = ms.analytics_id
    GROUP BY 1, 2, 3
),

cohort_summary AS (
    -- Count active members per month
    SELECT
        cohort_month,
        month_number,
        SUM(is_active_member) AS active_members
    FROM cohort_retention
    GROUP BY 1, 2
),

cohort_size AS (
    -- Total users in Month 0 for each cohort
    SELECT
        cohort_month,
        SUM(CASE WHEN month_number = 0 THEN active_members ELSE 0 END) AS cohort_size
    FROM cohort_summary
    GROUP BY 1
)

SELECT
    cs.cohort_month,
    cs.month_number,
    cs.active_members,
    ROUND(100.0 * cs.active_members / NULLIF(csz.cohort_size, 0), 1) AS retention_rate
FROM cohort_summary cs
JOIN cohort_size csz
    ON cs.cohort_month = csz.cohort_month
ORDER BY cs.cohort_month, cs.month_number