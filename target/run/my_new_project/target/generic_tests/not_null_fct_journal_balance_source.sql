
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select source
from analytics.dbt_cbuckley_stored_proc.fct_journal_balance
where source is null



  
  
      
    ) dbt_internal_test