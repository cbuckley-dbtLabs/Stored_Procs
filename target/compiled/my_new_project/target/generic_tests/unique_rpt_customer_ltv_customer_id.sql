
    
    

select
    customer_id as unique_field,
    count(*) as n_records

from analytics.dbt_cbuckley_stored_proc.rpt_customer_ltv
where customer_id is not null
group by customer_id
having count(*) > 1


