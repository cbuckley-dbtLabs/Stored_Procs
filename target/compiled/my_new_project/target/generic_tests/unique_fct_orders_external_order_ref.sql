
    
    

select
    external_order_ref as unique_field,
    count(*) as n_records

from analytics.dbt_cbuckley_stored_proc.fct_orders
where external_order_ref is not null
group by external_order_ref
having count(*) > 1


