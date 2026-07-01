select
    snapshot.warehouse_id,
    snapshot.product_id,
    product.sku,
    product.product_name,
    supplier.supplier_name,
    snapshot.qty_available,
    stock.qty_on_order as on_order
from analytics.dbt_cbuckley.rpt_inventory_snapshot as snapshot
inner join analytics.dbt_cbuckley.int_product_master as product
    on product.product_id = snapshot.product_id
left join analytics.dbt_cbuckley.int_suppliers as supplier
    on supplier.supplier_id = product.supplier_id
left join analytics.dbt_cbuckley.stg_stock_levels as stock
    on stock.warehouse_id = snapshot.warehouse_id
    and stock.product_id = snapshot.product_id
where snapshot.below_reorder = 1