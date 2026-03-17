 -- This code Generates 11 years of dates

{{ config(materialized='table') }}

WITH date_series AS (
    
    SELECT 
        DATEADD(day, SEQ4(), '2020-01-01') AS date_key
    FROM TABLE(GENERATOR(ROWCOUNT => 4018))
)
SELECT
    date_key,
   
    EXTRACT(YEAR FROM date_key) AS year,
    EXTRACT(MONTH FROM date_key) AS month_int,
    TO_CHAR(date_key, 'MMMM') AS month_name,
    TO_CHAR(date_key, 'YYYY-MM') AS month_year,
    
    
    EXTRACT(QUARTER FROM date_key) AS quarter,
    'Q' || EXTRACT(QUARTER FROM date_key) AS quarter_name,
    TO_CHAR(date_key, 'YYYY') || '-Q' || EXTRACT(QUARTER FROM date_key) AS year_quarter,

  
    EXTRACT(WEEKISO FROM date_key) AS iso_week_of_year,
    
  
    CASE 
        WHEN EXTRACT(DAYOFWEEKISO FROM date_key) IN (6, 7) THEN TRUE 
        ELSE FALSE 
    END AS is_weekend,


    CASE 
        WHEN EXTRACT(MONTH FROM date_key) IN (12, 1, 2) THEN 'Winter'
        WHEN EXTRACT(MONTH FROM date_key) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM date_key) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Autumn'
    END AS season
FROM date_series
WHERE date_key <= '2030-12-31'