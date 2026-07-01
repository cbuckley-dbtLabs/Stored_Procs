
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select grand_total
from analytics.dbt_cbuckley_stored_proc.fct_orders
where grand_total is null



  
  
      
    ) dbt_internal_test