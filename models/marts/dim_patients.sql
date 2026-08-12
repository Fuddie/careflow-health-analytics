-- Model: dim_patients
-- Purpose: Patient dimension with non-clinical demographic and payer attributes.
-- Grain: One row per patient_id.

with patients as (
    select
        patient_id,
        date_of_birth,
        sex,
        state,
        payer_type,
        registration_date,
        is_active
    from {{ ref('stg_patients') }}
)

select
    patient_id,
    date_of_birth,
    sex,
    state,
    payer_type,
    registration_date,
    is_active,

    -- Age bands support aggregate reporting without storing individual age values.
    case
        when date_diff(current_date(), date_of_birth, year) < 18 then 'UNDER_18'
        when date_diff(current_date(), date_of_birth, year) between 18 and 34 then '18_34'
        when date_diff(current_date(), date_of_birth, year) between 35 and 49 then '35_49'
        when date_diff(current_date(), date_of_birth, year) between 50 and 64 then '50_64'
        else '65_PLUS'
    end as age_band
from patients
