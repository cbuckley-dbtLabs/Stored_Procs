
    
    

select
    product_id as unique_field,
    count(*) as n_records

from analytics.dbt_cbuckley_stored_proc.rpt_top_products_by_revenue
where product_id is not null
group by product_id
having count(*) > 1


