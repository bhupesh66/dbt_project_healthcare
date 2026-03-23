{{
    config(
        materialized='incremental',
        unique_key='user_version_id',
        incremental_strategy='merge')
}}

with new_records as (
    select distinct analytics_id 
    from {{ref('users_stagging')}}

{% if is_incremental() %}
    where updated_at > (select MAX(valid_from) from {{this}})
{% endif %})
,

affected_users as (
    select  
    analytics_id ,
    gender,
    zipCode,
    birthdate,
    status,
    created_at,
    updated_at as valid_from 
    from 
    {{ref('users_stagging')}} where analytics_id  in (select analytics_id  from new_records)
)
,

versioning as (
    select 
    s.analytics_id ,
    s.gender,
    s.zipCode,
    s.birthdate,
    s.status,
    s.created_at,
    s.valid_from ,
    row_number() over (
        partition by s.analytics_id
        order by s.valid_from ASC
    ) as version_number,
    lead(s.valid_from) over (
        partition by 
        s.analytics_id 
        order by s.valid_from asc ) as valid_to
    from affected_users s ) 

select  
  MD5(CONCAT(analytics_id, CAST(version_number as STRING))) as user_version_id ,
 analytics_id,
 version_number,
 status,
 gender,
 zipCode,
 birthdate,
 created_at,
 valid_from,
 COALESCE(valid_to,'9999-12-31'::timestamp_ntz) as valid_to,
 case when valid_to is null then TRUE else FALSE end as is_current
 from versioning

