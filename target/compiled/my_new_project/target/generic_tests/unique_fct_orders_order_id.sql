
    
    

select
    order_id as unique_field,
    count(*) as n_records

from analytics.dbt_cbuckley_stored_proc.fct_orders
where order_id is not null
group by order_id
having count(*) > 1


