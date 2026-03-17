
--user iniital bmi is recorded on the basis of minimum measured_at date
--used incremental and bulk loading
{{
    config(
        materialized='incremental',
        unique_key="analytics_id"
    )
}}

with first_weight as (
    select
        analytics_id,
        measurement_value as weight_val,
        measured_at as weight_date,
        row_number() over (
            partition by analytics_id
            order by measured_at asc
        ) as rn
    from {{ ref('measurements_stagging') }}
    where measurement_type = 'weight'
      and measurement_value > 0
),
first_height as (
       select
        analytics_id,
        measurement_value as height_val,
        measured_at as height_date,
        row_number() over (
            partition by analytics_id
            order by measured_at asc
        ) as rn
    from {{ ref('measurements_stagging') }}
    where measurement_type = 'height'
      and measurement_value > 0
)

select 
  w.analytics_id,
  w.weight_val as initial_weight,
  h.height_val as initial_height,
  ROUND(
        w.weight_val / POWER(h.height_val / 100, 2), 
    2) AS initial_bmi,
COALESCE(w.weight_date, h.height_date) as initial_bmi_date
  from first_weight w 
  inner join first_height h
  on w.analytics_id=h.analytics_id and w.rn=1 and h.rn=1


{% if is_incremental() %}
    -- Only process users we havent calculated a full BMI for yet
    WHERE w.analytics_id NOT IN (SELECT analytics_id FROM {{ this }} WHERE initial_bmi IS NOT NULL)
{% endif %}










