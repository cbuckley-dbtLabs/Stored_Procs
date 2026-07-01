
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select row_id
from analytics.dbt_cbuckley_stored_proc.int_raw_orders_validated
where row_id is null



  
  
      
    ) dbt_internal_test