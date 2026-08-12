-- Model: stg_appointments
-- Purpose: Standardise appointment bookings and attendance outcomes.
-- Grain: One row per appointment_id.

with source as (
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
    from {{ source('careflow_raw', 'raw_appointments') }}
)

select
    cast(appointment_id as string) as appointment_id,
    cast(patient_id as string) as patient_id,
    cast(clinician_id as string) as clinician_id,
    cast(facility_id as string) as facility_id,
    trim(department) as department,
    cast(scheduled_at as timestamp) as scheduled_at,
    cast(booked_at as timestamp) as booked_at,
    upper(trim(appointment_status)) as appointment_status,
    cast(nullif(arrival_at, '') as timestamp) as arrival_at
from source
