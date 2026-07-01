
    
    

select
    journal_line_key as unique_field,
    count(*) as n_records

from analytics.dbt_cbuckley_stored_proc.fct_sales_journal_lines
where journal_line_key is not null
group by journal_line_key
having count(*) > 1


