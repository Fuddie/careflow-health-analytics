-- Model: stg_admissions
-- Purpose: Standardise inpatient admission and discharge events.
-- Grain: One row per admission_id.

with source as (
    select
        admission_id,
        patient_id,
        facility_id,
        department,
        admitted_at,
        discharged_at,
        discharge_disposition
    from {{ source('careflow_raw', 'raw_admissions') }}
)

select
    cast(admission_id as string) as admission_id,
    cast(patient_id as string) as patient_id,
    cast(facility_id as string) as facility_id,
    trim(department) as department,
    cast(admitted_at as timestamp) as admitted_at,
    cast(discharged_at as timestamp) as discharged_at,
    upper(trim(discharge_disposition)) as discharge_disposition
from source
