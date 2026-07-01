
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select product_id
from analytics.dbt_cbuckley_stored_proc.rpt_inventory_snapshot
where product_id is null



  
  
      
    ) dbt_internal_test