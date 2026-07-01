
  create or replace   view analytics.dbt_cbuckley_stored_proc.stg_warehouses
  
  
  
  
  as (
    select
    warehouseid as warehouse_id,
    warehousecode as warehouse_code,
    warehousename as warehouse_name,
    countrycode as country_code,
    isactive as is_active
from analytics.dbt_cbuckley_stored_proc.warehouse
  );

