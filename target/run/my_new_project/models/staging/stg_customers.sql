
  create or replace   view analytics.dbt_cbuckley_stored_proc.stg_customers
  
  
  
  
  as (
    select
    customerid as customer_id,
    customerno as customer_no,
    firstname as first_name,
    lastname as last_name,
    email,
    phone,
    countrycode as country_code,
    status
from analytics.dbt_cbuckley_stored_proc.customer
  );

