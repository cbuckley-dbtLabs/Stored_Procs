
  create or replace   view analytics.dbt_cbuckley_stored_proc.int_fx_rates
  
  
  
  
  as (
    with combined as (
    select from_currency, to_currency, rate_date, rate
    from analytics.dbt_cbuckley_stored_proc.stg_ref_fx_rates

    union all

    select from_currency, to_currency, rate_date, rate
    from analytics.dbt_cbuckley_stored_proc.stg_raw_fx_rates
    where rate_date is not null
      and rate is not null
),

direct_rates as (
    select
        from_currency,
        to_currency,
        rate_date,
        rate
    from combined
    qualify row_number() over (
        partition by from_currency, to_currency, rate_date
        order by rate desc
    ) = 1
),

inverse_rates as (
    select
        to_currency as from_currency,
        from_currency as to_currency,
        rate_date,
        1.0 / nullif(rate, 0) as rate
    from direct_rates
)

select * from direct_rates
union all
select * from inverse_rates
  );

