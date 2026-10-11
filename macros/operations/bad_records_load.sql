{% macro bad_records_load() %}
{# Loads intentionally bad records into RAW tables to demonstrate dbt test failures.
   Includes: duplicate keys, null fields, orphan references, negative values,
   invalid dates, unknown mappings, and cross-country mismatches.
   See project-data/bad_records/issue_catalog.csv for the full issue list.
   Run with: dbt run-operation bad_records_load #}

{% set database = 'EMPLOYEE_ANALYTICS' %}

{% set before_emp = run_query("SELECT COUNT(*) FROM " ~ database ~ ".RAW.EMPLOYEES") %}
{% set before_leave = run_query("SELECT COUNT(*) FROM " ~ database ~ ".RAW.LEAVE_EVENTS") %}
{{ log("Before load — EMPLOYEES: " ~ before_emp.columns[0].values()[0] ~ ", LEAVE_EVENTS: " ~ before_leave.columns[0].values()[0], info=True) }}

{% set _ = run_query("
    INSERT INTO " ~ database ~ ".RAW.EMPLOYEES
        (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, WORK_EMAIL, COUNTRY_CODE, DEPARTMENT_ID, HIRE_DATE, EMPLOYMENT_STATUS, SOURCE_UPDATED_AT)
    VALUES
        ('E001', 'Ava', 'Miller', 'ava.miller@example.us', 'US', 'US-ENG', '2022-04-04', 'ACTIVE', '2026-06-07'),
        ('E999', 'Bad', 'Null', NULL, 'US', 'US-HR', '2026-01-01', 'ACTIVE', '2026-06-07'),
        ('E998', 'Bad', 'Dept', 'unknown@example.us', 'US', 'US-UNKNOWN', '2026-01-01', 'ACTIVE', '2026-06-07'),
        ('E997', 'Bad', 'Country', 'country@example.us', 'XX', 'XX-ENG', '2026-01-01', 'ACTIVE', '2026-06-07')
") %}
{{ log("Inserted 4 bad employee records.", info=True) }}
{{ log("  E001 — duplicate employee ID (already exists in baseline)", info=True) }}
{{ log("  E999 — NULL work_email", info=True) }}
{{ log("  E998 — unknown department_id US-UNKNOWN", info=True) }}
{{ log("  E997 — unknown country_code XX", info=True) }}

{% set _ = run_query("
    INSERT INTO " ~ database ~ ".RAW.LEAVE_EVENTS
        (LEAVE_ID, EMPLOYEE_ID, COUNTRY_CODE, SOURCE_LEAVE_CODE, LEAVE_DATE, DAYS_TAKEN, SOURCE_UPDATED_AT)
    SELECT 'L00001', 'E001', 'US', 'PTO', '2026-06-02'::DATE, 1, '2026-06-07'::DATE
    UNION ALL SELECT 'L99901', 'E9999', 'US', 'PTO', '2026-06-02'::DATE, 1, '2026-06-07'::DATE
    UNION ALL SELECT 'L99902', 'E002', 'US', 'UNKNOWN', '2026-06-03'::DATE, 1, '2026-06-07'::DATE
    UNION ALL SELECT 'L99903', 'E003', 'US', 'PTO', '2026-06-03'::DATE, -2, '2026-06-07'::DATE
    UNION ALL SELECT 'L99904', 'E004', 'US', 'PTO', TRY_TO_DATE('not-a-date'), 1, '2026-06-07'::DATE
    UNION ALL SELECT 'L99905', NULL, 'IN', 'PL', '2026-06-04'::DATE, 1, '2026-06-07'::DATE
    UNION ALL SELECT 'L99906', 'E024', 'DE', 'URLAUB', '2026-06-05'::DATE, 1, '2026-06-07'::DATE
") %}
{{ log("Inserted 7 bad leave event records.", info=True) }}
{{ log("  L00001 — duplicate leave_id (already exists in baseline)", info=True) }}
{{ log("  L99901 — orphan employee_id E9999 (does not exist)", info=True) }}
{{ log("  L99902 — unmapped leave code UNKNOWN for US", info=True) }}
{{ log("  L99903 — negative days_taken (-2)", info=True) }}
{{ log("  L99904 — invalid date string (becomes NULL via TRY_TO_DATE)", info=True) }}
{{ log("  L99905 — NULL employee_id", info=True) }}
{{ log("  L99906 — employee/country mismatch (E024 is IN, event says DE)", info=True) }}

{% set after_emp = run_query("SELECT COUNT(*) FROM " ~ database ~ ".RAW.EMPLOYEES") %}
{% set after_leave = run_query("SELECT COUNT(*) FROM " ~ database ~ ".RAW.LEAVE_EVENTS") %}
{{ log("After load — EMPLOYEES: " ~ after_emp.columns[0].values()[0] ~ ", LEAVE_EVENTS: " ~ after_leave.columns[0].values()[0], info=True) }}

{{ log("Bad records loaded. Run dbt build --full-refresh to see test failures.", info=True) }}

{% endmacro %}
