
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select entry_date
from analytics.dbt_cbuckley_stored_proc.fct_journal_balance
where entry_date is null



  
  
      
    ) dbt_internal_test