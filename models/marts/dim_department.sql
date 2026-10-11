with departments as (

    select
        department_id,
        country_code,
        local_department_name,
        effective_from
    from {{ ref('stg_departments') }}

),

department_mapping as (

    select
        country_code,
        source_department_name,
        standard_department_name
    from {{ ref('department_mapping') }}

),

joined as (

    select
        d.department_id,
        d.country_code,
        dm.standard_department_name,
        d.effective_from
    from departments as d
    left join department_mapping as dm
        on d.country_code = dm.country_code
        and d.local_department_name = dm.source_department_name

)

select
    department_id,
    country_code,
    standard_department_name,
    effective_from
from joined
