-- Global Employee Analytics | Snowflake source setup for dbt tutorial
-- Matches global_employee_analytics_dbt_snowflake.zip
-- Execute sections 1–3 in Snowflake.
-- Upload CSVs to internal stages (example PUT commands in section 4, via SnowSQL/CLI).
-- Execute section 5 for the clean initial load.
-- DO NOT execute section 6 until the incremental dbt demonstration.

-- 1. DATABASE AND RAW SCHEMA
CREATE DATABASE IF NOT EXISTS EMPLOYEE_ANALYTICS;
CREATE SCHEMA IF NOT EXISTS EMPLOYEE_ANALYTICS.RAW;
USE DATABASE EMPLOYEE_ANALYTICS;
-- Raw Layer
CREATE SCHEMA IF NOT EXISTS RAW;

-- Staging Layer
CREATE SCHEMA IF NOT EXISTS STAGING;

-- Intermediate Layer
CREATE SCHEMA IF NOT EXISTS INTERMEDIATE;

-- Mart Layer
CREATE SCHEMA IF NOT EXISTS MARTS;
-- Analytics / Gold Layer
CREATE SCHEMA IF NOT EXISTS COMMON;

CREATE SCHEMA IF NOT EXISTS SEEDS;
CREATE SCHEMA IF NOT EXISTS SNAPSHOTS;

-- 2. SHARED CSV FORMAT
CREATE OR REPLACE FILE FORMAT FF_EMPLOYEE_CSV
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    EMPTY_FIELD_AS_NULL = TRUE
    NULL_IF = ('', 'NULL')
    DATE_FORMAT = 'YYYY-MM-DD'
    ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;

-- 3. INTERNAL STAGES + SOURCE TABLES
CREATE STAGE IF NOT EXISTS STG_EMPLOYEES
    FILE_FORMAT = FF_EMPLOYEE_CSV;


CREATE TABLE IF NOT EXISTS EMPLOYEES (
    EMPLOYEE_ID VARCHAR(20),
    FIRST_NAME VARCHAR(100),
    LAST_NAME VARCHAR(100),
    WORK_EMAIL VARCHAR(255),
    COUNTRY_CODE VARCHAR(2),
    DEPARTMENT_ID VARCHAR(30),
    HIRE_DATE DATE,
    EMPLOYMENT_STATUS VARCHAR(20),
    SOURCE_UPDATED_AT DATE
);

CREATE TABLE IF NOT EXISTS DEPARTMENTS (
    DEPARTMENT_ID VARCHAR(30),
    COUNTRY_CODE VARCHAR(2),
    LOCAL_DEPARTMENT_NAME VARCHAR(100),
    EFFECTIVE_FROM DATE
);

CREATE TABLE IF NOT EXISTS LEAVE_EVENTS (
    LEAVE_ID VARCHAR(20),
    EMPLOYEE_ID VARCHAR(20),
    COUNTRY_CODE VARCHAR(2),
    SOURCE_LEAVE_CODE VARCHAR(40),
    LEAVE_DATE DATE,
    DAYS_TAKEN NUMBER(10,0),
    SOURCE_UPDATED_AT DATE
);

-- 4. UPLOAD THE FILES (run PUT in SnowSQL/Snowflake CLI with access
--    to your LOCAL filesystem; NOT in the browser SQL worksheet).
--    Change the /absolute/path/... values to actual local paths.
-- PUT file:///absolute/path/global_employee_analytics/raw/employees/employees_us.csv
--     @EMPLOYEE_ANALYTICS.RAW.STG_EMPLOYEES AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file:///absolute/path/global_employee_analytics/raw/employees/employees_de.csv
--     @EMPLOYEE_ANALYTICS.RAW.STG_EMPLOYEES AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file:///absolute/path/global_employee_analytics/raw/employees/employees_in.csv
--     @EMPLOYEE_ANALYTICS.RAW.STG_EMPLOYEES AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file:///absolute/path/global_employee_analytics/raw/departments.csv
--     @EMPLOYEE_ANALYTICS.RAW.STG_DEPARTMENTS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file:///absolute/path/global_employee_analytics/raw/transactions/leave_initial.csv
--     @EMPLOYEE_ANALYTICS.RAW.STG_LEAVE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file:///absolute/path/global_employee_analytics/raw/transactions/leave_week2_delta.csv
--     @EMPLOYEE_ANALYTICS.RAW.STG_LEAVE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
--
-- Alternative (browser): Snowflake UI -> database/schema -> stages ->
-- upload files into the corresponding stages. Keep original filenames.
--
-- Check uploaded stage contents:
LIST @STG_EMPLOYEES;

-- 5. INITIAL BASELINE LOAD (run only AFTER uploading the CSVs)
COPY INTO EMPLOYEES
    FROM @STG_EMPLOYEES
    FILE_FORMAT = (FORMAT_NAME = FF_EMPLOYEE_CSV)
    FILES = ('employees_us.csv', 'employees_de.csv', 'employees_in.csv')
    ON_ERROR = ABORT_STATEMENT;

COPY INTO DEPARTMENTS
    FROM @STG_EMPLOYEES
    FILE_FORMAT = (FORMAT_NAME = FF_EMPLOYEE_CSV)
    FILES = ('departments.csv')
    ON_ERROR = ABORT_STATEMENT;

COPY INTO LEAVE_EVENTS
    FROM @STG_EMPLOYEES
    FILE_FORMAT = (FORMAT_NAME = FF_EMPLOYEE_CSV)
    FILES = ('leave_initial.csv')
    ON_ERROR = ABORT_STATEMENT;

-- Expected clean baseline: 30 employees, 9 departments, 90 leave events.
SELECT 'EMPLOYEES' AS SOURCE_TABLE, COUNT(*) AS ROW_COUNT FROM EMPLOYEES
UNION ALL
SELECT 'DEPARTMENTS', COUNT(*) FROM DEPARTMENTS
UNION ALL
SELECT 'LEAVE_EVENTS', COUNT(*) FROM LEAVE_EVENTS;

-- 6. LATER, DURING THE INCREMENTAL VIDEO DEMO ONLY:
--    Uncomment to append 12 new leave events (90 -> 102).
-- COPY INTO LEAVE_EVENTS
--     FROM @STG_LEAVE
--     FILE_FORMAT = (FORMAT_NAME = FF_EMPLOYEE_CSV)
--     FILES = ('leave_week2_delta.csv')
--     ON_ERROR = ABORT_STATEMENT;
--
-- SELECT COUNT(*) AS LEAVE_EVENT_ROWS_AFTER_DELTA FROM LEAVE_EVENTS;
--
-- NOTES:
-- - Do not load bad_records/ as part of the clean baseline.
-- - seeds/*.csv belong in your dbt project's seeds folder (dbt seed);
--   they are NOT Snowflake raw source CSVs.
-- - Snowflake COPY tracks files loaded into each table and may skip
--   already-loaded files on reruns. Do not set FORCE=TRUE casually.
-- - DDL is illustrative; adjust permissions/warehouse and source database
--   name to your account. Snowflake does not enforce ordinary PK/FK constraints.
