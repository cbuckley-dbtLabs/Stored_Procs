
  create or replace   view analytics.dbt_cbuckley_stored_proc.stg_raw_customers
  
  
  
  
  as (
    select
    row_number() over (order by customerno, email) as row_id,
    nullif(trim(customerno), '') as customer_no,
    nullif(trim(firstname), '') as first_name,
    nullif(trim(lastname), '') as last_name,
    nullif(trim(email), '') as email,
    nullif(trim(phone), '') as phone,
    nullif(trim(country), '') as country_raw
from analytics.dbt_cbuckley_stored_proc.raw_customer
  );

