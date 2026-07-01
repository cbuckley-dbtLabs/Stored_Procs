
    
    

with all_values as (

    select
        is_balanced as value_field,
        count(*) as n_records

    from analytics.dbt_cbuckley_stored_proc.fct_journal_balance
    group by is_balanced

)

select *
from all_values
where value_field not in (
    'True'
)


