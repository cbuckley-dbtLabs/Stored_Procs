
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  select *
from analytics.dbt_cbuckley_stored_proc.fct_journal_balance
where not is_balanced
  
  
      
    ) dbt_internal_test