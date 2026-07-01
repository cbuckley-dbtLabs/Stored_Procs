
    
    

with all_values as (

    select
        segment as value_field,
        count(*) as n_records

    from analytics.dbt_cbuckley_stored_proc.rpt_customer_ltv
    group by segment

)

select *
from all_values
where value_field not in (
    'VIP','REGULAR','LAPSED','NEW'
)


