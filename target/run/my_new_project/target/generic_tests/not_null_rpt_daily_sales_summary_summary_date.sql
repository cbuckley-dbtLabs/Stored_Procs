
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select summary_date
from analytics.dbt_cbuckley_stored_proc.rpt_daily_sales_summary
where summary_date is null



  
  
      
    ) dbt_internal_test