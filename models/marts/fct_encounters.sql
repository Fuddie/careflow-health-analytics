-- Model: fct_encounters
-- Purpose: Encounter fact table used for patient-volume and waiting-time reporting.
-- Grain: One row per encounter_id.

with encounters as (
    select
        encounter_id,
        appointment_id,
        patient_id,
        clinician_id,
        facility_id,
        department,
        encounter_type,
        arrival_at,
        consultation_start_at,
        consultation_end_at
    from {{ ref('stg_encounters') }}
)

select
    encounter_id,
    appointment_id,
    patient_id,
    clinician_id,
    facility_id,
    department,
    encounter_type,
    arrival_at,
    consultation_start_at,
    consultation_end_at,
    date(arrival_at) as encounter_date,

    -- Wait time measures arrival to consultation start.
    timestamp_diff(consultation_start_at, arrival_at, minute) as wait_time_minutes,

    -- Consultation duration measures consultation start to end.
    timestamp_diff(consultation_end_at, consultation_start_at, minute) as consultation_minutes
from encounters
