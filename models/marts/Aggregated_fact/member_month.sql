
--member month 

{{ config(
    materialized='table'
) }}

WITH dim_date AS (
    
    select
        date_key,
        month_name,
        year,
        DATE_TRUNC('month', date_key) AS month_start_date
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
    d.month_name, d.year, d.month_start_date
order by 
    d.month_start_date ASC


