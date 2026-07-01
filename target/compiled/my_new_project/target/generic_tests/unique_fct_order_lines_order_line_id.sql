
    
    

select
    order_line_id as unique_field,
    count(*) as n_records

from analytics.dbt_cbuckley_stored_proc.fct_order_lines
where order_line_id is not null
group by order_line_id
having count(*) > 1


