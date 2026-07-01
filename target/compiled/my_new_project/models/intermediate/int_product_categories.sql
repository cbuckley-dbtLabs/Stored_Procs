with raw_categories as (
    select distinct category_name
    from analytics.dbt_cbuckley_stored_proc.stg_raw_products
    where category_name is not null
      and category_name not in (
          select category_name from analytics.dbt_cbuckley_stored_proc.stg_product_categories
      )
)

select
    category_id,
    category_name,
    parent_category_id,
    default_margin_pct
from analytics.dbt_cbuckley_stored_proc.stg_product_categories

union all

select
    100000 + row_number() over (order by category_name) as category_id,
    category_name,
    null as parent_category_id,
    null as default_margin_pct
from raw_categories