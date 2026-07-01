
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select order_line_id
from analytics.dbt_cbuckley_stored_proc.fct_order_lines
where order_line_id is null



  
  
      
    ) dbt_internal_test