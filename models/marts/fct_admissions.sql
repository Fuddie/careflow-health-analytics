-- Model: fct_admissions
-- Purpose: Inpatient admission fact with length of stay and 30-day readmission logic.
-- Grain: One row per admission_id.

with sequenced as (
    select
        admission_id,
        patient_id,
        facility_id,
        department,
        admitted_at,
        discharged_at,
        discharge_disposition,
        length_of_stay_hours,
        next_admission_id,
        next_admitted_at
    from {{ ref('int_admission_sequence') }}
)

select
    admission_id,
    patient_id,
    facility_id,
    department,
    admitted_at,
    discharged_at,
    discharge_disposition,
    date(admitted_at) as admission_date,
    date(discharged_at) as discharge_date,
    length_of_stay_hours,
    safe_divide(length_of_stay_hours, 24.0) as length_of_stay_days,
    next_admission_id,
    next_admitted_at,

    -- A readmission is counted when the next admission occurs within 30 days
    -- after the current discharge. Negative/overlapping gaps are excluded.
    case
        when next_admitted_at is null then false
        when timestamp_diff(next_admitted_at, discharged_at, day) between 0 and 30 then true
        else false
    end as is_readmitted_within_30_days
from sequenced
