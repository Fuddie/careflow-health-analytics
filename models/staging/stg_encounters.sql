-- Model: stg_encounters
-- Purpose: Standardise completed patient encounter events.
-- Grain: One row per encounter_id.

with source as (
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
    from {{ source('careflow_raw', 'raw_encounters') }}
)

select
    cast(encounter_id as string) as encounter_id,
    cast(appointment_id as string) as appointment_id,
    cast(patient_id as string) as patient_id,
    cast(clinician_id as string) as clinician_id,
    cast(facility_id as string) as facility_id,
    trim(department) as department,
    upper(trim(encounter_type)) as encounter_type,
    cast(arrival_at as timestamp) as arrival_at,
    cast(consultation_start_at as timestamp) as consultation_start_at,
    cast(consultation_end_at as timestamp) as consultation_end_at
from source
