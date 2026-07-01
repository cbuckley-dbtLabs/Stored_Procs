
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select snapshot_date
from analytics.dbt_cbuckley_stored_proc.rpt_inventory_snapshot
where snapshot_date is null



  
  
      
    ) dbt_internal_test