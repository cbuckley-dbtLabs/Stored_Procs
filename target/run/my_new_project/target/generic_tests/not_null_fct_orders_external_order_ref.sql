
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select external_order_ref
from analytics.dbt_cbuckley_stored_proc.fct_orders
where external_order_ref is null



  
  
      
    ) dbt_internal_test