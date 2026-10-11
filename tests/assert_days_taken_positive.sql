select
    leave_id,
    days_taken
from {{ ref('fct_leave') }}
where days_taken <= 0
