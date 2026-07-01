
  create or replace   view analytics.dbt_cbuckley_stored_proc.stg_ref_fx_rates
  
  
  
  
  as (
    select
    fromcurrency as from_currency,
    tocurrency as to_currency,
    ratedate as rate_date,
    rate
from analytics.dbt_cbuckley_stored_proc.ref_fxrate
  );

