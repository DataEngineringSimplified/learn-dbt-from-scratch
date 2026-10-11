with employees as (

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
    from {{ ref('stg_employees') }}

),

departments as (

    select
        department_id,
        country_code,
        local_department_name
    from {{ ref('stg_departments') }}

),

department_mapping as (

    select
        country_code,
        source_department_name,
        standard_department_name
    from {{ ref('department_mapping') }}

),

country_mapping as (

    select
        country_code,
        country_name,
        region
    from {{ ref('country_mapping') }}

),

joined as (

    select
        e.employee_id,
        e.first_name,
        e.last_name,
        e.work_email,
        e.country_code,
        cm.country_name,
        cm.region,
        e.department_id,
        d.local_department_name,
        dm.standard_department_name,
        e.hire_date,
        e.employment_status,
        e.source_updated_at
    from employees as e
    left join departments as d
        on e.department_id = d.department_id
    left join department_mapping as dm
        on d.country_code = dm.country_code
        and d.local_department_name = dm.source_department_name
    left join country_mapping as cm
        on e.country_code = cm.country_code

)

select
    employee_id,
    first_name,
    last_name,
    work_email,
    country_code,
    country_name,
    region,
    department_id,
    local_department_name,
    standard_department_name,
    hire_date,
    employment_status,
    source_updated_at
from joined
