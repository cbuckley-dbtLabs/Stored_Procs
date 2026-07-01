
  create or replace   view analytics.dbt_cbuckley_stored_proc.stg_product_categories
  
  
  
  
  as (
    select
    categoryid as category_id,
    categoryname as category_name,
    parentcategoryid as parent_category_id,
    defaultmarginpct as default_margin_pct
from analytics.dbt_cbuckley_stored_proc.product_category
  );

