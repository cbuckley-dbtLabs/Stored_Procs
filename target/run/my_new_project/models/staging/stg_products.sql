
  create or replace   view analytics.dbt_cbuckley_stored_proc.stg_products
  
  
  
  
  as (
    select
    productid as product_id,
    sku,
    productname as product_name,
    categoryid as category_id,
    supplierid as supplier_id,
    unitcost as unit_cost,
    listprice as list_price,
    weight_g,
    status
from analytics.dbt_cbuckley_stored_proc.product
  );

