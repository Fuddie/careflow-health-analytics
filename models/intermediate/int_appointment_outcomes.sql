-- Model: int_appointment_outcomes
-- Purpose: Centralise appointment outcome flags and booking timing.
-- Grain: One row per appointment_id.

with appointments as (
    select
        appointment_id,
        patient_id,
        clinician_id,
        facility_id,
        department,
        scheduled_at,
        booked_at,
        appointment_status,
        arrival_at
    from {{ ref('stg_appointments') }}
)

select
    appointment_id,
    patient_id,
    clinician_id,
    facility_id,
    department,
    scheduled_at,
    booked_at,
    appointment_status,
    arrival_at,
    date(scheduled_at) as appointment_date,

    -- Centralised status flags keep downstream KPI logic consistent.
    appointment_status = 'COMPLETED' as is_completed,
    appointment_status = 'NO_SHOW' as is_no_show,
    appointment_status = 'CANCELLED' as is_cancelled,

    -- Lead time shows how far in advance an appointment was booked.
    timestamp_diff(scheduled_at, booked_at, hour) as booking_lead_hours
from appointments
