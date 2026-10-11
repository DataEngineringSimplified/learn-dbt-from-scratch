{% macro initial_data_load() %}
{# Loads the baseline dataset into RAW tables: 30 employees, 9 departments, 90 leave events.
   Truncates tables first to allow safe re-runs.
   Run with: dbt run-operation initial_data_load #}

{% set database = 'EMPLOYEE_ANALYTICS' %}

{% set _ = run_query("TRUNCATE TABLE IF EXISTS " ~ database ~ ".RAW.EMPLOYEES") %}
{% set _ = run_query("TRUNCATE TABLE IF EXISTS " ~ database ~ ".RAW.DEPARTMENTS") %}
{% set _ = run_query("TRUNCATE TABLE IF EXISTS " ~ database ~ ".RAW.LEAVE_EVENTS") %}
{{ log("Tables truncated for clean load.", info=True) }}

{% set _ = run_query("
    INSERT INTO " ~ database ~ ".RAW.EMPLOYEES
        (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, WORK_EMAIL, COUNTRY_CODE, DEPARTMENT_ID, HIRE_DATE, EMPLOYMENT_STATUS, SOURCE_UPDATED_AT)
    VALUES
        ('E001', 'Ava', 'Miller', 'ava.miller@example.us', 'US', 'US-ENG', '2022-04-04', 'ACTIVE', '2026-05-31'),
        ('E002', 'Liam', 'Johnson', 'liam.johnson@example.us', 'US', 'US-HR', '2022-07-06', 'ACTIVE', '2026-05-31'),
        ('E003', 'Sophia', 'Brown', 'sophia.brown@example.us', 'US', 'US-FIN', '2022-10-07', 'ACTIVE', '2026-05-31'),
        ('E004', 'Noah', 'Davis', 'noah.davis@example.us', 'US', 'US-ENG', '2023-01-08', 'ACTIVE', '2026-05-31'),
        ('E005', 'Isabella', 'Wilson', 'isabella.wilson@example.us', 'US', 'US-HR', '2023-04-11', 'ACTIVE', '2026-05-31'),
        ('E006', 'Ethan', 'Moore', 'ethan.moore@example.us', 'US', 'US-FIN', '2023-07-13', 'ACTIVE', '2026-05-31'),
        ('E007', 'Mia', 'Taylor', 'mia.taylor@example.us', 'US', 'US-ENG', '2023-10-14', 'ACTIVE', '2026-05-31'),
        ('E008', 'Lucas', 'Anderson', 'lucas.anderson@example.us', 'US', 'US-HR', '2024-01-15', 'ACTIVE', '2026-05-31'),
        ('E009', 'Amelia', 'Thomas', 'amelia.thomas@example.us', 'US', 'US-FIN', '2024-04-17', 'ACTIVE', '2026-05-31'),
        ('E010', 'Oliver', 'Jackson', 'oliver.jackson@example.us', 'US', 'US-ENG', '2024-07-19', 'ACTIVE', '2026-05-31'),
        ('E011', 'Emma', 'Schmidt', 'emma.schmidt@example.de', 'DE', 'DE-TECH', '2022-05-31', 'ACTIVE', '2026-05-31'),
        ('E012', 'Ben', 'Mueller', 'ben.mueller@example.de', 'DE', 'DE-PERS', '2022-09-01', 'ACTIVE', '2026-05-31'),
        ('E013', 'Mia', 'Weber', 'mia.weber@example.de', 'DE', 'DE-FIN', '2022-12-03', 'ACTIVE', '2026-05-31'),
        ('E014', 'Paul', 'Fischer', 'paul.fischer@example.de', 'DE', 'DE-TECH', '2023-03-06', 'ACTIVE', '2026-05-31'),
        ('E015', 'Hannah', 'Wagner', 'hannah.wagner@example.de', 'DE', 'DE-PERS', '2023-06-07', 'ACTIVE', '2026-05-31'),
        ('E016', 'Leon', 'Becker', 'leon.becker@example.de', 'DE', 'DE-FIN', '2023-09-08', 'ACTIVE', '2026-05-31'),
        ('E017', 'Lena', 'Hoffmann', 'lena.hoffmann@example.de', 'DE', 'DE-TECH', '2023-12-10', 'ACTIVE', '2026-05-31'),
        ('E018', 'Felix', 'Schulz', 'felix.schulz@example.de', 'DE', 'DE-PERS', '2024-03-12', 'ACTIVE', '2026-05-31'),
        ('E019', 'Clara', 'Koch', 'clara.koch@example.de', 'DE', 'DE-FIN', '2024-06-13', 'ACTIVE', '2026-05-31'),
        ('E020', 'Jonas', 'Richter', 'jonas.richter@example.de', 'DE', 'DE-TECH', '2024-09-14', 'ACTIVE', '2026-05-31'),
        ('E021', 'Aarav', 'Sharma', 'aarav.sharma@example.in', 'IN', 'IN-TECH', '2022-07-27', 'ACTIVE', '2026-05-31'),
        ('E022', 'Ananya', 'Iyer', 'ananya.iyer@example.in', 'IN', 'IN-PEOPLE', '2022-10-28', 'ACTIVE', '2026-05-31'),
        ('E023', 'Vivaan', 'Patel', 'vivaan.patel@example.in', 'IN', 'IN-ACCT', '2023-01-29', 'ACTIVE', '2026-05-31'),
        ('E024', 'Diya', 'Nair', 'diya.nair@example.in', 'IN', 'IN-TECH', '2023-05-02', 'ACTIVE', '2026-05-31'),
        ('E025', 'Aditya', 'Rao', 'aditya.rao@example.in', 'IN', 'IN-PEOPLE', '2023-08-03', 'ACTIVE', '2026-05-31'),
        ('E026', 'Ishita', 'Mehta', 'ishita.mehta@example.in', 'IN', 'IN-ACCT', '2023-11-04', 'ACTIVE', '2026-05-31'),
        ('E027', 'Arjun', 'Gupta', 'arjun.gupta@example.in', 'IN', 'IN-TECH', '2024-02-05', 'ACTIVE', '2026-05-31'),
        ('E028', 'Saanvi', 'Reddy', 'saanvi.reddy@example.in', 'IN', 'IN-PEOPLE', '2024-05-08', 'ACTIVE', '2026-05-31'),
        ('E029', 'Kabir', 'Singh', 'kabir.singh@example.in', 'IN', 'IN-ACCT', '2024-08-09', 'ACTIVE', '2026-05-31'),
        ('E030', 'Meera', 'Joshi', 'meera.joshi@example.in', 'IN', 'IN-TECH', '2024-11-10', 'ACTIVE', '2026-05-31')
") %}
{{ log("Loaded 30 employees.", info=True) }}

{% set _ = run_query("
    INSERT INTO " ~ database ~ ".RAW.DEPARTMENTS
        (DEPARTMENT_ID, COUNTRY_CODE, LOCAL_DEPARTMENT_NAME, EFFECTIVE_FROM)
    VALUES
        ('US-ENG', 'US', 'Engineering', '2026-01-01'),
        ('US-HR', 'US', 'Human Resources', '2026-01-01'),
        ('US-FIN', 'US', 'Finance', '2026-01-01'),
        ('DE-TECH', 'DE', 'Technik', '2026-01-01'),
        ('DE-PERS', 'DE', 'Personalwesen', '2026-01-01'),
        ('DE-FIN', 'DE', 'Finanzen', '2026-01-01'),
        ('IN-TECH', 'IN', 'Technology', '2026-01-01'),
        ('IN-PEOPLE', 'IN', 'People Operations', '2026-01-01'),
        ('IN-ACCT', 'IN', 'Accounts', '2026-01-01')
") %}
{{ log("Loaded 9 departments.", info=True) }}

{% set _ = run_query("
    INSERT INTO " ~ database ~ ".RAW.LEAVE_EVENTS
        (LEAVE_ID, EMPLOYEE_ID, COUNTRY_CODE, SOURCE_LEAVE_CODE, LEAVE_DATE, DAYS_TAKEN, SOURCE_UPDATED_AT)
    VALUES
        ('L00001', 'E001', 'US', 'PTO', '2026-01-05', 2, '2026-05-31'),
        ('L00002', 'E008', 'US', 'SICK', '2026-01-10', 1, '2026-05-31'),
        ('L00003', 'E005', 'US', 'UNPAID', '2026-01-15', 1, '2026-05-31'),
        ('L00004', 'E002', 'US', 'PTO', '2026-01-20', 1, '2026-05-31'),
        ('L00005', 'E009', 'US', 'SICK', '2026-01-25', 1, '2026-05-31'),
        ('L00006', 'E006', 'US', 'UNPAID', '2026-01-30', 1, '2026-05-31'),
        ('L00007', 'E003', 'US', 'PTO', '2026-02-04', 2, '2026-05-31'),
        ('L00008', 'E010', 'US', 'SICK', '2026-02-09', 1, '2026-05-31'),
        ('L00009', 'E007', 'US', 'UNPAID', '2026-02-14', 1, '2026-05-31'),
        ('L00010', 'E004', 'US', 'PTO', '2026-02-19', 1, '2026-05-31'),
        ('L00011', 'E001', 'US', 'SICK', '2026-02-24', 1, '2026-05-31'),
        ('L00012', 'E008', 'US', 'UNPAID', '2026-03-01', 1, '2026-05-31'),
        ('L00013', 'E005', 'US', 'PTO', '2026-03-06', 2, '2026-05-31'),
        ('L00014', 'E002', 'US', 'SICK', '2026-03-11', 1, '2026-05-31'),
        ('L00015', 'E009', 'US', 'UNPAID', '2026-03-16', 1, '2026-05-31'),
        ('L00016', 'E006', 'US', 'PTO', '2026-03-21', 1, '2026-05-31'),
        ('L00017', 'E003', 'US', 'SICK', '2026-03-26', 1, '2026-05-31'),
        ('L00018', 'E010', 'US', 'UNPAID', '2026-03-31', 1, '2026-05-31'),
        ('L00019', 'E007', 'US', 'PTO', '2026-04-05', 2, '2026-05-31'),
        ('L00020', 'E004', 'US', 'SICK', '2026-04-10', 1, '2026-05-31'),
        ('L00021', 'E001', 'US', 'UNPAID', '2026-04-15', 1, '2026-05-31'),
        ('L00022', 'E008', 'US', 'PTO', '2026-04-20', 1, '2026-05-31'),
        ('L00023', 'E005', 'US', 'SICK', '2026-04-25', 1, '2026-05-31'),
        ('L00024', 'E002', 'US', 'UNPAID', '2026-04-30', 1, '2026-05-31'),
        ('L00025', 'E009', 'US', 'PTO', '2026-05-05', 2, '2026-05-31'),
        ('L00026', 'E006', 'US', 'SICK', '2026-05-10', 1, '2026-05-31'),
        ('L00027', 'E003', 'US', 'UNPAID', '2026-05-15', 1, '2026-05-31'),
        ('L00028', 'E010', 'US', 'PTO', '2026-05-20', 1, '2026-05-31'),
        ('L00029', 'E007', 'US', 'SICK', '2026-01-05', 1, '2026-05-31'),
        ('L00030', 'E004', 'US', 'UNPAID', '2026-01-10', 1, '2026-05-31'),
        ('L01001', 'E012', 'DE', 'KRANK', '2026-01-08', 2, '2026-05-31'),
        ('L01002', 'E019', 'DE', 'UNBEZAHLT', '2026-01-13', 1, '2026-05-31'),
        ('L01003', 'E016', 'DE', 'URLAUB', '2026-01-18', 1, '2026-05-31'),
        ('L01004', 'E013', 'DE', 'KRANK', '2026-01-23', 1, '2026-05-31'),
        ('L01005', 'E020', 'DE', 'UNBEZAHLT', '2026-01-28', 1, '2026-05-31'),
        ('L01006', 'E017', 'DE', 'URLAUB', '2026-02-02', 1, '2026-05-31'),
        ('L01007', 'E014', 'DE', 'KRANK', '2026-02-07', 2, '2026-05-31'),
        ('L01008', 'E011', 'DE', 'UNBEZAHLT', '2026-02-12', 1, '2026-05-31'),
        ('L01009', 'E018', 'DE', 'URLAUB', '2026-02-17', 1, '2026-05-31'),
        ('L01010', 'E015', 'DE', 'KRANK', '2026-02-22', 1, '2026-05-31'),
        ('L01011', 'E012', 'DE', 'UNBEZAHLT', '2026-02-27', 1, '2026-05-31'),
        ('L01012', 'E019', 'DE', 'URLAUB', '2026-03-04', 1, '2026-05-31'),
        ('L01013', 'E016', 'DE', 'KRANK', '2026-03-09', 2, '2026-05-31'),
        ('L01014', 'E013', 'DE', 'UNBEZAHLT', '2026-03-14', 1, '2026-05-31'),
        ('L01015', 'E020', 'DE', 'URLAUB', '2026-03-19', 1, '2026-05-31'),
        ('L01016', 'E017', 'DE', 'KRANK', '2026-03-24', 1, '2026-05-31'),
        ('L01017', 'E014', 'DE', 'UNBEZAHLT', '2026-03-29', 1, '2026-05-31'),
        ('L01018', 'E011', 'DE', 'URLAUB', '2026-04-03', 1, '2026-05-31'),
        ('L01019', 'E018', 'DE', 'KRANK', '2026-04-08', 2, '2026-05-31'),
        ('L01020', 'E015', 'DE', 'UNBEZAHLT', '2026-04-13', 1, '2026-05-31'),
        ('L01021', 'E012', 'DE', 'URLAUB', '2026-04-18', 1, '2026-05-31'),
        ('L01022', 'E019', 'DE', 'KRANK', '2026-04-23', 1, '2026-05-31'),
        ('L01023', 'E016', 'DE', 'UNBEZAHLT', '2026-04-28', 1, '2026-05-31'),
        ('L01024', 'E013', 'DE', 'URLAUB', '2026-05-03', 1, '2026-05-31'),
        ('L01025', 'E020', 'DE', 'KRANK', '2026-05-08', 2, '2026-05-31'),
        ('L01026', 'E017', 'DE', 'UNBEZAHLT', '2026-05-13', 1, '2026-05-31'),
        ('L01027', 'E014', 'DE', 'URLAUB', '2026-05-18', 1, '2026-05-31'),
        ('L01028', 'E011', 'DE', 'KRANK', '2026-05-23', 1, '2026-05-31'),
        ('L01029', 'E018', 'DE', 'UNBEZAHLT', '2026-01-08', 1, '2026-05-31'),
        ('L01030', 'E015', 'DE', 'URLAUB', '2026-01-13', 1, '2026-05-31'),
        ('L02001', 'E023', 'IN', 'LOP', '2026-01-11', 2, '2026-05-31'),
        ('L02002', 'E030', 'IN', 'PL', '2026-01-16', 1, '2026-05-31'),
        ('L02003', 'E027', 'IN', 'SL', '2026-01-21', 1, '2026-05-31'),
        ('L02004', 'E024', 'IN', 'LOP', '2026-01-26', 1, '2026-05-31'),
        ('L02005', 'E021', 'IN', 'PL', '2026-01-31', 1, '2026-05-31'),
        ('L02006', 'E028', 'IN', 'SL', '2026-02-05', 1, '2026-05-31'),
        ('L02007', 'E025', 'IN', 'LOP', '2026-02-10', 2, '2026-05-31'),
        ('L02008', 'E022', 'IN', 'PL', '2026-02-15', 1, '2026-05-31'),
        ('L02009', 'E029', 'IN', 'SL', '2026-02-20', 1, '2026-05-31'),
        ('L02010', 'E026', 'IN', 'LOP', '2026-02-25', 1, '2026-05-31'),
        ('L02011', 'E023', 'IN', 'PL', '2026-03-02', 1, '2026-05-31'),
        ('L02012', 'E030', 'IN', 'SL', '2026-03-07', 1, '2026-05-31'),
        ('L02013', 'E027', 'IN', 'LOP', '2026-03-12', 2, '2026-05-31'),
        ('L02014', 'E024', 'IN', 'PL', '2026-03-17', 1, '2026-05-31'),
        ('L02015', 'E021', 'IN', 'SL', '2026-03-22', 1, '2026-05-31'),
        ('L02016', 'E028', 'IN', 'LOP', '2026-03-27', 1, '2026-05-31'),
        ('L02017', 'E025', 'IN', 'PL', '2026-04-01', 1, '2026-05-31'),
        ('L02018', 'E022', 'IN', 'SL', '2026-04-06', 1, '2026-05-31'),
        ('L02019', 'E029', 'IN', 'LOP', '2026-04-11', 2, '2026-05-31'),
        ('L02020', 'E026', 'IN', 'PL', '2026-04-16', 1, '2026-05-31'),
        ('L02021', 'E023', 'IN', 'SL', '2026-04-21', 1, '2026-05-31'),
        ('L02022', 'E030', 'IN', 'LOP', '2026-04-26', 1, '2026-05-31'),
        ('L02023', 'E027', 'IN', 'PL', '2026-05-01', 1, '2026-05-31'),
        ('L02024', 'E024', 'IN', 'SL', '2026-05-06', 1, '2026-05-31'),
        ('L02025', 'E021', 'IN', 'LOP', '2026-05-11', 2, '2026-05-31'),
        ('L02026', 'E028', 'IN', 'PL', '2026-05-16', 1, '2026-05-31'),
        ('L02027', 'E025', 'IN', 'SL', '2026-05-21', 1, '2026-05-31'),
        ('L02028', 'E022', 'IN', 'LOP', '2026-01-06', 1, '2026-05-31'),
        ('L02029', 'E029', 'IN', 'PL', '2026-01-11', 1, '2026-05-31'),
        ('L02030', 'E026', 'IN', 'SL', '2026-01-16', 1, '2026-05-31')
") %}
{{ log("Loaded 90 leave events.", info=True) }}

{% set row_counts = run_query("
    SELECT 'EMPLOYEES' AS TBL, COUNT(*) AS CNT FROM " ~ database ~ ".RAW.EMPLOYEES
    UNION ALL
    SELECT 'DEPARTMENTS', COUNT(*) FROM " ~ database ~ ".RAW.DEPARTMENTS
    UNION ALL
    SELECT 'LEAVE_EVENTS', COUNT(*) FROM " ~ database ~ ".RAW.LEAVE_EVENTS
") %}
{% for row in row_counts %}
    {{ log(row[0] ~ ": " ~ row[1] ~ " rows", info=True) }}
{% endfor %}

{{ log("Initial data load complete. Expected: 30 employees, 9 departments, 90 leave events.", info=True) }}

{% endmacro %}