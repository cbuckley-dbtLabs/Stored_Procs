
  create or replace   view analytics.dbt_cbuckley_stored_proc.stg_config_param
  
  
  
  
  as (
    select
    paramkey as param_key,
    paramvalue as param_value,
    paramtype as param_type,
    description
from analytics.dbt_cbuckley_stored_proc.config_param
  );

