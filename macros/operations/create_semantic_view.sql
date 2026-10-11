{% macro create_semantic_view() %}
{# Creates or replaces the EMPLOYEE_LEAVE_ANALYTICS semantic view in the MARTS schema.
   Uses SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML with the full YAML spec.
   Run with: dbt run-operation create_semantic_view #}

{% set sv_yaml %}
name: EMPLOYEE_LEAVE_ANALYTICS
description: >-
  Employee leave analytics model covering employee demographics, department
  structure, and leave transactions across US, Germany, and India. Supports
  analysis of leave patterns by region, department, leave type, and individual employee.
tables:
  - name: DIM_EMPLOYEE
    base_table:
      database: EMPLOYEE_ANALYTICS
      schema: MARTS
      table: DIM_EMPLOYEE
    primary_key:
      columns:
        - EMPLOYEE_ID
    dimensions:
      - name: EMPLOYEE_ID
        expr: EMPLOYEE_ID
        data_type: VARCHAR
        description: Unique identifier for each employee.
      - name: EMPLOYEE_NAME
        expr: EMPLOYEE_NAME
        data_type: VARCHAR
        description: Full name of the employee.
      - name: COUNTRY_CODE
        expr: COUNTRY_CODE
        data_type: VARCHAR
        description: Two-letter ISO country code.
      - name: COUNTRY_NAME
        expr: COUNTRY_NAME
        data_type: VARCHAR
        description: Full country name (United States, Germany, India).
      - name: REGION
        expr: REGION
        data_type: VARCHAR
        description: Geographic region (NA, EU, APAC).
      - name: DEPARTMENT_ID
        expr: DEPARTMENT_ID
        data_type: VARCHAR
        description: Country-specific department identifier.
      - name: DEPARTMENT_NAME
        expr: DEPARTMENT_NAME
        data_type: VARCHAR
        description: Standardized department name (Engineering, Human Resources, Finance).
      - name: EMPLOYMENT_STATUS
        expr: EMPLOYMENT_STATUS
        data_type: VARCHAR
        description: Current employment status (ACTIVE, INACTIVE).
    time_dimensions:
      - name: HIRE_DATE
        expr: HIRE_DATE
        data_type: DATE
        description: Date the employee was hired.
  - name: DIM_DEPARTMENT
    base_table:
      database: EMPLOYEE_ANALYTICS
      schema: MARTS
      table: DIM_DEPARTMENT
    primary_key:
      columns:
        - DEPARTMENT_ID
    dimensions:
      - name: DEPARTMENT_ID
        expr: DEPARTMENT_ID
        data_type: VARCHAR
        description: Country-specific department identifier.
      - name: COUNTRY_CODE
        expr: COUNTRY_CODE
        data_type: VARCHAR
        description: Two-letter ISO country code.
      - name: STANDARD_DEPARTMENT_NAME
        expr: STANDARD_DEPARTMENT_NAME
        data_type: VARCHAR
        description: Standardized department name across all countries.
    time_dimensions:
      - name: EFFECTIVE_FROM
        expr: EFFECTIVE_FROM
        data_type: DATE
        description: Date from which the department record is effective.
  - name: FCT_LEAVE
    base_table:
      database: EMPLOYEE_ANALYTICS
      schema: MARTS
      table: FCT_LEAVE
    dimensions:
      - name: LEAVE_ID
        expr: LEAVE_ID
        data_type: VARCHAR
        description: Unique identifier for each leave transaction.
      - name: EMPLOYEE_ID
        expr: EMPLOYEE_ID
        data_type: VARCHAR
        description: Foreign key to the employee dimension.
      - name: STANDARD_LEAVE_TYPE
        expr: STANDARD_LEAVE_TYPE
        data_type: VARCHAR
        description: Standardized leave type (Annual Leave, Sick Leave, Unpaid Leave).
      - name: IS_PAID
        expr: IS_PAID
        data_type: BOOLEAN
        description: Whether the leave is paid (TRUE) or unpaid (FALSE).
      - name: DAYS_TAKEN
        expr: DAYS_TAKEN
        data_type: NUMBER
        description: Number of leave days taken in this transaction.
    time_dimensions:
      - name: LEAVE_DATE
        expr: LEAVE_DATE
        data_type: DATE
        description: Date the leave was taken.
      - name: SOURCE_UPDATED_AT
        expr: SOURCE_UPDATED_AT
        data_type: DATE
        description: Timestamp of the last source update for this record.
relationships:
  - name: FCT_LEAVE_TO_DIM_EMPLOYEE
    left_table: FCT_LEAVE
    right_table: DIM_EMPLOYEE
    join_type: inner
    relationship_type: many_to_one
    relationship_columns:
      - left_column: EMPLOYEE_ID
        right_column: EMPLOYEE_ID
verified_queries:
  - name: total_leave_days_by_region
    question: What is the total leave days taken by region?
    sql: >-
      SELECT e.REGION, SUM(f.DAYS_TAKEN) AS total_leave_days
      FROM EMPLOYEE_ANALYTICS.MARTS.FCT_LEAVE AS f
      JOIN EMPLOYEE_ANALYTICS.MARTS.DIM_EMPLOYEE AS e ON f.EMPLOYEE_ID = e.EMPLOYEE_ID
      GROUP BY e.REGION ORDER BY total_leave_days DESC
    verified_by: dbt macro
  - name: leave_by_department_and_type
    question: How are leave days distributed by department and leave type?
    sql: >-
      SELECT e.DEPARTMENT_NAME, f.STANDARD_LEAVE_TYPE, SUM(f.DAYS_TAKEN) AS total_days
      FROM EMPLOYEE_ANALYTICS.MARTS.FCT_LEAVE AS f
      JOIN EMPLOYEE_ANALYTICS.MARTS.DIM_EMPLOYEE AS e ON f.EMPLOYEE_ID = e.EMPLOYEE_ID
      GROUP BY e.DEPARTMENT_NAME, f.STANDARD_LEAVE_TYPE
      ORDER BY e.DEPARTMENT_NAME, total_days DESC
    verified_by: dbt macro
  - name: employee_count_by_country
    question: How many employees are there in each country?
    sql: >-
      SELECT e.COUNTRY_NAME, COUNT(DISTINCT e.EMPLOYEE_ID) AS employee_count
      FROM EMPLOYEE_ANALYTICS.MARTS.DIM_EMPLOYEE AS e
      GROUP BY e.COUNTRY_NAME ORDER BY employee_count DESC
    verified_by: dbt macro
  - name: top_10_employees_most_leave
    question: Who are the top 10 employees with the most leave days?
    sql: >-
      SELECT e.EMPLOYEE_NAME, e.DEPARTMENT_NAME, e.COUNTRY_NAME,
      SUM(f.DAYS_TAKEN) AS total_leave_days
      FROM EMPLOYEE_ANALYTICS.MARTS.FCT_LEAVE AS f
      JOIN EMPLOYEE_ANALYTICS.MARTS.DIM_EMPLOYEE AS e ON f.EMPLOYEE_ID = e.EMPLOYEE_ID
      GROUP BY e.EMPLOYEE_NAME, e.DEPARTMENT_NAME, e.COUNTRY_NAME
      ORDER BY total_leave_days DESC LIMIT 10
    verified_by: dbt macro
  - name: paid_vs_unpaid_breakdown
    question: What is the breakdown of paid vs unpaid leave by leave type?
    sql: >-
      SELECT f.STANDARD_LEAVE_TYPE, f.IS_PAID, SUM(f.DAYS_TAKEN) AS total_days,
      COUNT(*) AS transaction_count
      FROM EMPLOYEE_ANALYTICS.MARTS.FCT_LEAVE AS f
      GROUP BY f.STANDARD_LEAVE_TYPE, f.IS_PAID ORDER BY total_days DESC
    verified_by: dbt macro
{% endset %}

{% set escaped_yaml = sv_yaml | replace("'", "''") %}

{% set _ = run_query("
    CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
        'EMPLOYEE_ANALYTICS.MARTS',
        '" ~ escaped_yaml ~ "',
        FALSE
    )
") %}

{{ log("Semantic view EMPLOYEE_ANALYTICS.MARTS.EMPLOYEE_LEAVE_ANALYTICS created.", info=True) }}

{% endmacro %}
