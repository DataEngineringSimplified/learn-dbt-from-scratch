with employees as (

    select
        employee_id,
        first_name,
        last_name,
        country_code,
        country_name,
        region,
        department_id,
        standard_department_name,
        employment_status,
        hire_date
    from {{ ref('int_employees_standardized') }}

)

select
    employee_id,
    first_name || ' ' || last_name as employee_name,
    country_code,
    country_name,
    region,
    department_id,
    standard_department_name as department_name,
    employment_status,
    hire_date
from employees
