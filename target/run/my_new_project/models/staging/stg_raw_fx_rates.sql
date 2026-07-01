
  create or replace   view analytics.dbt_cbuckley_stored_proc.stg_raw_fx_rates
  
  
  
  
  as (
    select
    row_number() over (order by fromcurrency, tocurrency, ratedatetext) as row_id,
    nullif(trim(fromcurrency), '') as from_currency,
    nullif(trim(tocurrency), '') as to_currency,
    try_to_date(nullif(trim(ratedatetext), '')) as rate_date,
    try_to_decimal(nullif(trim(ratetext), ''), 18, 8) as rate
from analytics.dbt_cbuckley_stored_proc.raw_fxrate
  );

