select
    countrycode as country_code,
    countryname as country_name,
    region,
    defaultcurrency as default_currency
from analytics.dbt_cbuckley.ref_country