
    
    

select
    row_id as unique_field,
    count(*) as n_records

from analytics.dbt_cbuckley_stored_proc.int_raw_orders_validated
where row_id is not null
group by row_id
having count(*) > 1


