{% macro setup_infrastructure() %}
{# Ensures all database objects exist before running dbt models.
   Run with: dbt run-operation setup_infrastructure #}

{% set database = 'EMPLOYEE_ANALYTICS' %}

{% set setup_statements = [
    'CREATE DATABASE IF NOT EXISTS ' ~ database,
    'CREATE SCHEMA IF NOT EXISTS ' ~ database ~ '.RAW',
    'CREATE SCHEMA IF NOT EXISTS ' ~ database ~ '.STAGING',
    'CREATE SCHEMA IF NOT EXISTS ' ~ database ~ '.INTERMEDIATE',
    'CREATE SCHEMA IF NOT EXISTS ' ~ database ~ '.MARTS',
    'CREATE SCHEMA IF NOT EXISTS ' ~ database ~ '.SEEDS',
    'CREATE SCHEMA IF NOT EXISTS ' ~ database ~ '.SNAPSHOTS',
    'CREATE SCHEMA IF NOT EXISTS ' ~ database ~ '.DBT_PROJECTS'
] %}

{% for stmt in setup_statements %}
    {% set _ = run_query(stmt) %}
{% endfor %}
{{ log("Schemas created or verified.", info=True) }}

{% set _ = run_query("
    CREATE FILE FORMAT IF NOT EXISTS " ~ database ~ ".RAW.FF_EMPLOYEE_CSV
        TYPE = CSV
        SKIP_HEADER = 1
        FIELD_DELIMITER = ','
        FIELD_OPTIONALLY_ENCLOSED_BY = '\"'
        EMPTY_FIELD_AS_NULL = TRUE
        NULL_IF = ('', 'NULL')
        DATE_FORMAT = 'YYYY-MM-DD'
        ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
") %}
{{ log("File format FF_EMPLOYEE_CSV created or verified.", info=True) }}

{% set _ = run_query("
    CREATE STAGE IF NOT EXISTS " ~ database ~ ".RAW.STG_EMPLOYEES
        FILE_FORMAT = " ~ database ~ ".RAW.FF_EMPLOYEE_CSV
        DIRECTORY = (ENABLE = TRUE)
") %}
{% set _ = run_query("
    CREATE STAGE IF NOT EXISTS " ~ database ~ ".RAW.STG_DEPARTMENTS
        FILE_FORMAT = " ~ database ~ ".RAW.FF_EMPLOYEE_CSV
        DIRECTORY = (ENABLE = TRUE)
") %}
{% set _ = run_query("
    CREATE STAGE IF NOT EXISTS " ~ database ~ ".RAW.STG_LEAVE
        FILE_FORMAT = " ~ database ~ ".RAW.FF_EMPLOYEE_CSV
        DIRECTORY = (ENABLE = TRUE)
") %}
{{ log("Internal stages created or verified.", info=True) }}

{% set _ = run_query("
    CREATE TABLE IF NOT EXISTS " ~ database ~ ".RAW.EMPLOYEES (
        EMPLOYEE_ID     VARCHAR(20),
        FIRST_NAME      VARCHAR(100),
        LAST_NAME       VARCHAR(100),
        WORK_EMAIL      VARCHAR(255),
        COUNTRY_CODE    VARCHAR(2),
        DEPARTMENT_ID   VARCHAR(30),
        HIRE_DATE       DATE,
        EMPLOYMENT_STATUS VARCHAR(20),
        SOURCE_UPDATED_AT DATE
    )
") %}

{% set _ = run_query("
    CREATE TABLE IF NOT EXISTS " ~ database ~ ".RAW.DEPARTMENTS (
        DEPARTMENT_ID           VARCHAR(30),
        COUNTRY_CODE            VARCHAR(2),
        LOCAL_DEPARTMENT_NAME   VARCHAR(100),
        EFFECTIVE_FROM          DATE
    )
") %}

{% set _ = run_query("
    CREATE TABLE IF NOT EXISTS " ~ database ~ ".RAW.LEAVE_EVENTS (
        LEAVE_ID            VARCHAR(20),
        EMPLOYEE_ID         VARCHAR(20),
        COUNTRY_CODE        VARCHAR(2),
        SOURCE_LEAVE_CODE   VARCHAR(40),
        LEAVE_DATE          DATE,
        DAYS_TAKEN          NUMBER(10,0),
        SOURCE_UPDATED_AT   DATE
    )
") %}
{{ log("Source tables created or verified.", info=True) }}

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

{{ log("Infrastructure setup complete.", info=True) }}

{% endmacro %}
