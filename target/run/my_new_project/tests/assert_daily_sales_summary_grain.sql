
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  select
    summary_date,
    warehouse_id,
    category_id,
    count(*) as row_count
from analytics.dbt_cbuckley_stored_proc.rpt_daily_sales_summary
group by 1, 2, 3
having count(*) > 1
  
  
      
    ) dbt_internal_test