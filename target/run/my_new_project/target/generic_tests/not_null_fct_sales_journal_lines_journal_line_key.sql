
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select journal_line_key
from analytics.dbt_cbuckley_stored_proc.fct_sales_journal_lines
where journal_line_key is null



  
  
      
    ) dbt_internal_test