
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select account_code
from analytics.dbt_cbuckley_stored_proc.fct_sales_journal_lines
where account_code is null



  
  
      
    ) dbt_internal_test