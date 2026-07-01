select
    loyaltyaccountid as loyalty_account_id,
    customerid as customer_id,
    tier,
    pointsbalance as points_balance,
    lifetimepoints as lifetime_points
from analytics.dbt_cbuckley_stored_proc.loyalty_account