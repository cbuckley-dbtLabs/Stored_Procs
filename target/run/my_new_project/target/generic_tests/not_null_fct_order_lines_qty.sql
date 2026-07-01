
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select qty
from analytics.dbt_cbuckley_stored_proc.fct_order_lines
where qty is null



  
  
      
    ) dbt_internal_test