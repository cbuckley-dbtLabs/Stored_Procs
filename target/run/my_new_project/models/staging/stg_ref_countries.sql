
  create or replace   view analytics.dbt_cbuckley_stored_proc.stg_ref_countries
  
  
  
  
  as (
    select
    countrycode as country_code,
    countryname as country_name,
    region,
    defaultcurrency as default_currency
from analytics.dbt_cbuckley_stored_proc.ref_country
  );

