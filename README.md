# Global Employee Analytics — dbt on Snowflake

A beginner-friendly dbt project that transforms raw employee, department, and leave data into analytics-ready dimension and fact tables on Snowflake.

## What this project does

Takes raw HR data from a small global organization (US, Germany, India — 30 employees across 3 departments) and builds a clean analytics layer using dbt's staging, intermediate, and marts pattern.

## Project structure

```
models/
  staging/         -- views over RAW tables (source references)
  intermediate/    -- enriched views with seed lookups
  marts/           -- final dimension and fact tables
seeds/             -- CSV mapping files loaded by dbt seed
macros/
  helpers/         -- reusable SQL helpers (days_to_hours, schema routing)
  operations/      -- run-operation scripts (setup, data load, semantic view)
tests/             -- singular SQL tests
__sample_data/     -- reference CSVs (not loaded by dbt)
```

## Sample data overview (`__sample_data/`)

Reference copies of the source data. These are NOT loaded by dbt — they exist for documentation and manual loading via Snowflake stages or the `initial_data_load` macro.

### `initial_data/` — baseline source records

| File | Records | Description |
|------|---------|-------------|
| `employees/employees_us.csv` | 10 | US employees (E001–E010) |
| `employees/employees_de.csv` | 10 | Germany employees (E011–E020) |
| `employees/employees_in.csv` | 10 | India employees (E021–E030) |
| `departments.csv` | 9 | 3 departments x 3 countries |
| `transactions/leave_initial.csv` | 90 | Baseline leave events |
| `transactions/leave_week2_delta.csv` | 12 | Incremental batch (adds 90 → 102) |

### `seeds/` — mapping files (also in `seeds/` at project root)

| File | Purpose |
|------|---------|
| `country_mapping.csv` | Country codes → names and regions (US→NA, DE→EU, IN→APAC) |
| `department_mapping.csv` | Local department names → standardized names |
| `leave_type_mapping.csv` | Country-specific leave codes → standard types and paid/unpaid |

### `bad_records/` — intentionally invalid data for testing

| File | Records | Issues |
|------|---------|--------|
| `employees_bad.csv` | 4 | Duplicate ID, NULL email, unknown department, unknown country |
| `leave_bad.csv` | 7 | Duplicate ID, orphan FK, unmapped code, negative days, invalid date, NULL employee, country mismatch |
| `issue_catalog.csv` | — | Documents each bad record and the dbt test it triggers |

## Run order (Snowflake-native deployment)

```sql
-- 1. Create infrastructure
EXECUTE DBT PROJECT EMPLOYEE_ANALYTICS.DBT_PROJECTS.EMPLOYEE_ANALYTICS_PROJECT
  ARGS='run-operation setup_infrastructure';

-- 2. Load baseline data
EXECUTE DBT PROJECT EMPLOYEE_ANALYTICS.DBT_PROJECTS.EMPLOYEE_ANALYTICS_PROJECT
  ARGS='run-operation initial_data_load';

-- 3. Build everything (seed + run + test)
EXECUTE DBT PROJECT EMPLOYEE_ANALYTICS.DBT_PROJECTS.EMPLOYEE_ANALYTICS_PROJECT
  ARGS='build --full-refresh';

-- 4. Deploy semantic view
EXECUTE DBT PROJECT EMPLOYEE_ANALYTICS.DBT_PROJECTS.EMPLOYEE_ANALYTICS_PROJECT
  ARGS='run-operation create_semantic_view';

-- 5. (Later) Load incremental batch and run
EXECUTE DBT PROJECT EMPLOYEE_ANALYTICS.DBT_PROJECTS.EMPLOYEE_ANALYTICS_PROJECT
  ARGS='run-operation incremental_data_load';
EXECUTE DBT PROJECT EMPLOYEE_ANALYTICS.DBT_PROJECTS.EMPLOYEE_ANALYTICS_PROJECT
  ARGS='run --select fct_leave';

-- 6. (Optional) Load bad records to demonstrate test failures
EXECUTE DBT PROJECT EMPLOYEE_ANALYTICS.DBT_PROJECTS.EMPLOYEE_ANALYTICS_PROJECT
  ARGS='run-operation bad_records_load';
```

## Snowflake schema layout

| Schema | Contents |
|--------|----------|
| RAW | Source tables (EMPLOYEES, DEPARTMENTS, LEAVE_EVENTS) |
| SEEDS | Mapping tables from dbt seed |
| STAGING | Staging views (stg_*) |
| INTERMEDIATE | Enriched views (int_*) |
| MARTS | Dimension tables, fact table, semantic view |
| DBT_PROJECTS | Deployed dbt project object |
