select
    warehouseid as warehouse_id,
    productid as product_id,
    qtyonhand as qty_on_hand,
    qtyallocated as qty_allocated,
    qtyonorder as qty_on_order,
    reorderpoint as reorder_point,
    reorderqty as reorder_qty
from analytics.dbt_cbuckley.stock_level