
  create or replace   view analytics.dbt_cbuckley_stored_proc.int_suppliers
  
  
  
  
  as (
    with raw_suppliers as (
    select distinct supplier_name
    from analytics.dbt_cbuckley_stored_proc.stg_raw_products
    where supplier_name is not null
      and supplier_name not in (
          select supplier_name from analytics.dbt_cbuckley_stored_proc.stg_suppliers
      )
)

select
    supplier_id,
    supplier_name,
    country_code,
    lead_time_days,
    is_active
from analytics.dbt_cbuckley_stored_proc.stg_suppliers

union all

select
    100000 + row_number() over (order by supplier_name) as supplier_id,
    supplier_name,
    null as country_code,
    7 as lead_time_days,
    1 as is_active
from raw_suppliers
  );

