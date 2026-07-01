
  create or replace   view analytics.dbt_cbuckley_stored_proc.stg_gl_accounts
  
  
  
  
  as (
    select
    glaccountid as gl_account_id,
    accountcode as account_code,
    accountname as account_name,
    accounttype as account_type,
    isactive as is_active
from analytics.dbt_cbuckley_stored_proc.gl_account
  );

