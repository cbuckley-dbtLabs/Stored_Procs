select
    fromcurrency as from_currency,
    tocurrency as to_currency,
    ratedate as rate_date,
    rate
from analytics.dbt_cbuckley_stored_proc.ref_fxrate