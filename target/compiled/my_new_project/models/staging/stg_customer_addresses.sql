select
    addressid as address_id,
    customerid as customer_id,
    addresstype as address_type,
    line1,
    line2,
    city,
    postcode as post_code,
    countrycode as country_code,
    isdefault as is_default
from analytics.dbt_cbuckley_stored_proc.customer_address