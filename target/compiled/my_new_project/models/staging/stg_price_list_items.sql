select
    pricelistitemid as price_list_item_id,
    pricelistid as price_list_id,
    productid as product_id,
    unitprice as unit_price
from analytics.dbt_cbuckley_stored_proc.price_list_item