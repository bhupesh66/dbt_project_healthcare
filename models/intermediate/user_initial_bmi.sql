{{
    config(
        materialized='incremental',
        unique_key='analytics_id'
    )
}}

with first_weight as (
    select analytics_id,
    measurement_value as weight_val,
    measured_at as weight_date,
    row_number() over 
    (
        partition by analytics_id
        order by measured_at asc
    ) as rn 
    from {{ref('measurements_stagging')}}
    where measurement_type='weight'
    AND visible = TRUE
),
first_height as (

    select analytics_id,
    measurement_value as height_val,
    measured_at as height_date,
    row_number() over 
    ( partition by analytics_id 
        order by measured_at asc
    ) as rn from {{ref('measurements_stagging')}}
    where measurement_type='height' and visible = TRUE
)

select fw.analytics_id,
fw.weight_val as initial_weight,
fh.height_val as initial_height,
round(fw.weight_val/(power(fh.height_val/100,2))) as initial_bmi,
COALESCE(weight_date,height_date) as initial_bmi_date 
from 
first_weight fw
inner join 
first_height fh 
on fw.analytics_id=fh.analytics_id 
and fw.rn=1 and fh.rn=1


{% if is_incremental() %}
    -- Only process users we havent calculated a full BMI for yet
    where fw.analytics_id not in (select analytics_id from {{ this }} where initial_bmi is not null)
{% endif %}
