
--incremental handling 

-- One row per user per program week, shows each user's weight and cumulative change from their baseline.
-- Negative weight_change_kg = weight lost.
-- we have added bmi and classified bmi into classes for further analytics.


{{ config(
    materialized='incremental',
    unique_key='user_week_id',
    incremental_strategy='merge'
) }}
--taken constant height coz height doent change often so taken latest height 
WITH height_fix as (
    
    select 
        analytics_id,
        initial_height 
     from (
        select
            analytics_id,
            initial_height, 
            ROW_NUMBER() OVER (partition by analytics_id order by  initial_bmi_date desc) as rn
        from {{ ref('user_initial_bmi') }}
    ) where  rn = 1
),

new_measurements as (
    select 
        m.analytics_id,
        m.measurement_value as current_weight,
        m.measured_at,
        i.initial_weight,
        h.initial_height, 
        i.initial_bmi_date as initial_measured_at,
        DATEDIFF('week', i.initial_bmi_date, m.measured_at) as week_number
     from {{ ref('measurements_stagging') }} m
    inner join  {{ ref('user_initial_bmi') }} i on m.analytics_id = i.analytics_id
    inner join height_fix h ON m.analytics_id = h.analytics_id 
    where m.measurement_type = 'weight'

    {% if is_incremental() %}
    and m.measured_at > (select MAX(last_measurement_date_in_week) from {{ this }})
    {% endif %}
),
--This is needed to make a week non redundent because one user can measure their weight mutiple times in a single week so it takes most latest one

weekly_deduped AS (
    select
        MD5(CONCAT(analytics_id, '_', week_number)) AS user_week_id,
        analytics_id,
        week_number,
        current_weight,
        initial_weight,
        
        (initial_height / 100.0) as height_m,
        measured_at,
        ROW_NUMBER() OVER (
            PARTITION BY analytics_id, week_number 
            ORDER BY measured_at DESC
        ) as latest_in_week
    from new_measurements
)

select
    user_week_id,
    analytics_id,week_number,
    current_weight,
    initial_weight,
     round(current_weight / (height_m * height_m), 2) AS current_bmi,
    
  --bmi classification useful while doing analysis like  eg: users are successful in becoming healthier
    case 
        when (current_weight /  (height_m * height_m)) >= 35 then 'Obese Class II'
        when (current_weight / (height_m * height_m)) >= 30 then 'Obese Class I'
        when (current_weight / (height_m * height_m)) >= 25 then 'Overweight'
        when (current_weight / (height_m * height_m)) >= 18.5 then 'Healthy Range'
       else 'underweight' end as  bmi_category,
 (ROW_NUMBER() OVER (PARTITION BY analytics_id ORDER BY week_number) - 1) AS measurement_sequence,
    ROUND(current_weight - initial_weight, 2) AS weight_change_kg,
    measured_at AS last_measurement_date_in_week
from weekly_deduped
where latest_in_week = 1