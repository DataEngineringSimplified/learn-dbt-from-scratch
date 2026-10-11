{% macro incremental_data_load() %}
{# Loads 12 new leave events into RAW.LEAVE_EVENTS for the incremental dbt demonstration.
   After running this, execute dbt run --select fct_leave to process the delta.
   Expected result: fct_leave grows from 90 to 102 rows.
   Run with: dbt run-operation incremental_data_load #}

{% set database = 'EMPLOYEE_ANALYTICS' %}

{% set before = run_query("SELECT COUNT(*) FROM " ~ database ~ ".RAW.LEAVE_EVENTS") %}
{{ log("Leave events before load: " ~ before.columns[0].values()[0] ~ " rows", info=True) }}

{% set _ = run_query("
    INSERT INTO " ~ database ~ ".RAW.LEAVE_EVENTS
        (LEAVE_ID, EMPLOYEE_ID, COUNTRY_CODE, SOURCE_LEAVE_CODE, LEAVE_DATE, DAYS_TAKEN, SOURCE_UPDATED_AT)
    VALUES
        ('L00031', 'E003', 'US', 'SICK', '2026-06-01', 1, '2026-06-15'),
        ('L00032', 'E006', 'US', 'UNPAID', '2026-06-03', 1, '2026-06-15'),
        ('L00033', 'E009', 'US', 'PTO', '2026-06-05', 1, '2026-06-15'),
        ('L00034', 'E002', 'US', 'SICK', '2026-06-07', 1, '2026-06-15'),
        ('L01031', 'E013', 'DE', 'KRANK', '2026-06-02', 1, '2026-06-15'),
        ('L01032', 'E016', 'DE', 'UNBEZAHLT', '2026-06-04', 1, '2026-06-15'),
        ('L01033', 'E019', 'DE', 'URLAUB', '2026-06-06', 1, '2026-06-15'),
        ('L01034', 'E012', 'DE', 'KRANK', '2026-06-08', 1, '2026-06-15'),
        ('L02031', 'E023', 'IN', 'SL', '2026-06-03', 1, '2026-06-15'),
        ('L02032', 'E026', 'IN', 'LOP', '2026-06-05', 1, '2026-06-15'),
        ('L02033', 'E029', 'IN', 'PL', '2026-06-07', 1, '2026-06-15'),
        ('L02034', 'E022', 'IN', 'SL', '2026-06-09', 1, '2026-06-15')
") %}
{{ log("Inserted 12 incremental leave events.", info=True) }}

{% set after = run_query("SELECT COUNT(*) FROM " ~ database ~ ".RAW.LEAVE_EVENTS") %}
{{ log("Leave events after load: " ~ after.columns[0].values()[0] ~ " rows", info=True) }}
{{ log("Incremental load complete. Now run: dbt run --select fct_leave", info=True) }}

{% endmacro %}