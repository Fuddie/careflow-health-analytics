-- Test: exactly one appointment outcome flag must be true.
-- A returned row means the appointment status logic is inconsistent.

select
    appointment_id,
    is_completed,
    is_no_show,
    is_cancelled
from {{ ref('fct_appointments') }}
where
    cast(is_completed as int64)
    + cast(is_no_show as int64)
    + cast(is_cancelled as int64) != 1
