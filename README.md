# Stored_Procs
Repo of stored procs for use with dbt wizard migration
# RetailDW Stored Procedures

Database: **RetailDW** (SQL Server 2016+)

This repo holds the stored procedures and supporting schema for the retail
operational + reporting database. Originally split out of the old `RMS`
monolith back in 2017, migrated piecemeal ever since.

> NOTE (2019): the nightly batch is orchestrated by SQL Agent job
> `JOB_NightlyBatch` which calls `etl.usp_RunNightlyBatch`. Do **not** run the
> ETL procs by hand on prod unless you know what you're doing — they assume the
> staging tables have already been loaded by the SSIS package.

## Layout

| Folder | Schema(s) | What lives here |
|--------|-----------|-----------------|
| `schema/`            | all        | DDL: schemas, tables, seed reference data |
| `procedures/util`    | `util`     | logging, error handling, config, batch control |
| `procedures/customer`| `dbo`      | customer + loyalty maintenance |
| `procedures/inventory`| `inv`     | stock levels, movements, purchase orders, reorder |
| `procedures/orders`  | `sales`    | order capture, payment, fulfilment, returns |
| `procedures/pricing` | `sales`,`dbo` | price lookups, promotions, discounts |
| `procedures/finance` | `fin`      | journals, settlement, reconciliation |
| `procedures/reporting`| `rpt`     | daily/periodic summary builds |
| `procedures/etl`     | `etl`,`stg`| staging loads + nightly orchestration |

## Naming (mostly...)

- `usp_` prefix for procedures. A few older ones are just `sp_` or `proc_` —
  leave them, things reference them by name.
- `_v2` suffix means the original is still around and probably still called
  somewhere. Check before deleting.

## Build order

Run `schema/` files in numeric order, then load `procedures/util` first
(everything depends on `util.usp_LogStart` / `util.usp_LogEnd`), then the rest
in any order.

## Known issues / TODO

- `sales.usp_RecalcOrderTotals` and `sales.usp_RecalculateOrderTotals_v2` both
  exist. Pretty sure only one is correct. (see SALES-412)
- FX rates load is flaky, sometimes `etl.usp_LoadFxRates` silently no-ops if the
  feed is late.
- reorder thresholds are hardcoded in a couple of places AND in `util.ConfigParam`.
- nobody is 100% sure what `dbo.proc_FixCustomerDupes` does anymore. it's run
  manually every few months.
