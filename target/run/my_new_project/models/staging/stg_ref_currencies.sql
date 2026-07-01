
  create or replace   view analytics.dbt_cbuckley_stored_proc.stg_ref_currencies
  
  
  
  
  as (
    select
    currencycode as currency_code,
    currencyname as currency_name,
    minorunits as minor_units
from analytics.dbt_cbuckley_stored_proc.ref_currency
  );

