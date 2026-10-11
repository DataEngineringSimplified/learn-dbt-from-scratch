{{
    config(
        materialized='incremental',
        unique_key='leave_id'
    )
}}

with leave_data as (

    select
        leave_id,
        employee_id,
        leave_date,
        standard_leave_type,
        is_paid,
        days_taken,
        source_updated_at
    from {{ ref('int_leave_standardized') }}

)

select
    leave_id,
    employee_id,
    leave_date,
    standard_leave_type,
    is_paid,
    days_taken,
    {{ days_to_hours('days_taken') }} as hours_taken,
    source_updated_at
from leave_data

{% if is_incremental() %}
    where source_updated_at > (select max(source_updated_at) from {{ this }})
{% endif %}
