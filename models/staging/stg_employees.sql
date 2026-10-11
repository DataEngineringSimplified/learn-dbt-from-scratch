with source as (

    select
        employee_id,
        first_name,
        last_name,
        work_email,
        country_code,
        department_id,
        hire_date,
        employment_status,
        source_updated_at
    from {{ source('raw', 'employees') }}

)

select
    employee_id,
    first_name,
    last_name,
    work_email,
    country_code,
    department_id,
    hire_date,
    employment_status,
    source_updated_at
from source
