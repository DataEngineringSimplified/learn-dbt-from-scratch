# Data Dictionary / Model Contract

**Employees** (`employees_*.csv`): `employee_id` (stable, unique text PK), `first_name`, `last_name`, `work_email` (synthetic), `country_code` (US/DE/IN), `department_id` (FK), `hire_date` (ISO date), `employment_status`, `source_updated_at` (ISO date).

**Departments** (`departments.csv`): `department_id` (country-specific PK), `country_code`, `local_department_name`, `effective_from`.

**Leave events** (`leave_*.csv`): `leave_id` (unique cross-batch PK), `employee_id` (FK), `country_code` (must match employee), `source_leave_code` (regional mapping), `leave_date` (ISO date), `days_taken` (>0), `source_updated_at`.

**Country seed**: `country_code`, `country_name`, `region`, `currency_code`.

**Department seed**: composite mapping key `(country_code, source_department_name)`, standardized department label.

**Leave seed**: composite mapping key `(country_code, source_leave_code)`, `standard_leave_type`, `is_paid` (text TRUE/FALSE for seed conversion).

**Recommended marts**:
- `dim_employee`: one current row per employee; `employee_id` PK, country/region, standardized department.
- `dim_department`: one row per `department_id` or one per standardized department depending on desired grain; choose explicitly.
- `fct_leave`: one row per `leave_id`; employee FK, date, normalized leave type and paid flag, days taken.

**Important**: `bad_records/` is intentionally invalid and should never be combined with the clean baseline without a scripted test demo.
