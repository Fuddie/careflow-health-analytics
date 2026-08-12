-- Model: int_admission_sequence
-- Purpose: Order admissions for each patient and identify the next admission.
-- Grain: One row per admission_id.

with admissions as (
    select
        admission_id,
        patient_id,
        facility_id,
        department,
        admitted_at,
        discharged_at,
        discharge_disposition
    from {{ ref('stg_admissions') }}
)

select
    admission_id,
    patient_id,
    facility_id,
    department,
    admitted_at,
    discharged_at,
    discharge_disposition,

    -- Length of stay is measured in hours so partial-day stays are preserved.
    timestamp_diff(discharged_at, admitted_at, hour) as length_of_stay_hours,

    -- LEAD identifies the patient's next admission without a self-join.
    lead(admission_id) over (
        partition by patient_id
        order by admitted_at
    ) as next_admission_id,

    lead(admitted_at) over (
        partition by patient_id
        order by admitted_at
    ) as next_admitted_at
from admissions
