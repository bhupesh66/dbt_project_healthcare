{{config(
    materialized='incremental',
    unique_key='user_week_id',
    incremental_strategy='merge'
)}}


with height_fix as 
(
    select 
    analytics_id,
    initial_height
    from (
        select
         analytics_id,
        initial_height,
        row_number()over (partition by analytics_id order by 
        initial_bmi_date desc) as rn 
        from {{ ref('user_initial_bmi') }}
    ) where rn=1
),
new_records as (
    select distinct analytics_id 
    from {{ref('measurements_stagging')}}

{% if is_incremental() %}
    where measured_at  > (select MAX(last_measurement_date_in_week) from {{this}})
{% endif %})
,

new_measurements as (

    select 
    m.analytics_id,
    m.measurement_value as current_weight,
    m.measured_at,
    i.initial_weight,
    h.initial_height,
    i.initial_bmi_date ,
    DATEDIFF(week,i.initial_bmi_date,m.measured_at) as week_number
     from {{ ref('measurements_stagging') }} m
     inner join {{ ref('user_initial_bmi') }} i  on 
     m.analytics_id = i.analytics_id 
     inner join 
     height_fix h 
     ON
     m.analytics_id = h.analytics_id 
     where
     m.measurement_type = 'weight'
     
     and m.analytics_id 
      in 
      (select analytics_id  from new_records)
     
)

,
weekely_dedup as (
    select 
     MD5(CONCAT(analytics_id, '_', CAST(week_number AS STRING))) AS user_week_id,
     analytics_id,
     week_number,
     current_weight,
     initial_weight,
     (initial_height / 100.0) as height_m,
     measured_at,
    row_number() over (
        partition by 
        analytics_id,
        week_number 
         order by 
        measured_at DESC
     ) as latest_in_week
     from new_measurements
)

select 
user_week_id,
analytics_id,
week_number,
current_weight,
initial_weight,
round(current_weight / (height_m * height_m), 2) AS current_bmi,
case 
       when (current_weight /  (height_m * height_m)) >= 35 then 'Obese Class II'
        when (current_weight / (height_m * height_m)) >= 30 then 'Obese Class I'
        when (current_weight / (height_m * height_m)) >= 25 then 'Overweight'
        when (current_weight / (height_m * height_m)) >= 18.5 then 'Healthy Range'
       else 'underweight' end as  bmi_category,
    (ROW_NUMBER() over (partition by  analytics_id ORDER BY week_number) - 1) AS measurement_sequence,
     ROUND(current_weight - initial_weight, 2) AS cummulatives_weight_change,
    
    ROUND(current_weight - lag(current_weight) over (partition by analytics_id order by week_number), 2)
        
     as delta_incremental_change,
    measured_at AS last_measurement_date_in_week
 from weekely_dedup
  where latest_in_week = 1



