
--member month 

{{ config(
    materialized='table'
) }}

WITH dim_date AS (
    
    select
        date_key,
        month_name,
        year,
        month_int,
    from {{ ref('date_dim') }}
    where date_key <= CURRENT_DATE()
    
),

member_status as (
    
    select
        analytics_id,
        valid_from,
        valid_to
    from {{ ref('dim_user') }}
    where status = 'member'
    and visible = TRUE
     and is_removed = false
)

select
    d.month_name,
    d.year,
    COUNT(distinct m.analytics_id) as total_members
from dim_date d
inner join member_status m
 on m.valid_from <= d.date_key and m.valid_to > d.date_key
  where d.date_key = LAST_DAY(d.date_key)
group by
    d.month_name, d.year, d.month_int
order by 
    d.year,d.month_int ASC





-- WITH month_boundaries AS (
--     SELECT
--         DATE_TRUNC('month', date_key) AS month_start,
--         LAST_DAY(date_key) AS month_end,
--         month_name,
--         year,
--         month_int
--     FROM {{ ref('date_dim') }}
--     WHERE date_key <= CURRENT_DATE()
--     GROUP BY 1, 2, 3, 4, 5 
-- ),

-- SELECT
--     m_bounds.month_name,
--     m_bounds.year,
--     COUNT(DISTINCT m.analytics_id) AS full_month_active_members
-- FROM month_boundaries m_bounds
-- INNER JOIN member_status m
--     ON  m.valid_from <= m_bounds.month_start  
--     AND (m.valid_to > m_bounds.month_end OR m.valid_to IS NULL) 
-- GROUP BY 1, 2, m_bounds.month_int
-- ORDER BY m_bounds.year, m_bounds.month_int ASC