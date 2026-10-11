with leave_events as (

    select
        leave_id,
        employee_id,
        country_code,
        source_leave_code,
        leave_date,
        days_taken,
        source_updated_at
    from {{ ref('stg_leave_events') }}

),

leave_type_mapping as (

    select
        country_code,
        source_leave_code,
        standard_leave_type,
        is_paid
    from {{ ref('leave_type_mapping') }}

),

joined as (

    select
        le.leave_id,
        le.employee_id,
        le.country_code,
        le.source_leave_code,
        ltm.standard_leave_type,
        ltm.is_paid,
        le.leave_date,
        le.days_taken,
        le.source_updated_at
    from leave_events as le
    left join leave_type_mapping as ltm
        on le.country_code = ltm.country_code
        and le.source_leave_code = ltm.source_leave_code

)

select
    leave_id,
    employee_id,
    country_code,
    source_leave_code,
    standard_leave_type,
    is_paid,
    leave_date,
    days_taken,
    source_updated_at
from joined
