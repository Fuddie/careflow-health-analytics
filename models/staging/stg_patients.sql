-- Model: stg_patients
-- Purpose: Standardise synthetic patient attributes for downstream dimensions and marts.
-- Grain: One row per patient_id.

with source as (
    select
        patient_id,
        date_of_birth,
        sex,
        state,
        payer_type,
        registration_date,
        is_active
    from {{ source('careflow_raw', 'raw_patients') }}
)

select
    cast(patient_id as string) as patient_id,
    cast(date_of_birth as date) as date_of_birth,
    upper(trim(sex)) as sex,
    upper(trim(state)) as state,
    upper(trim(payer_type)) as payer_type,
    cast(registration_date as date) as registration_date,
    cast(is_active as bool) as is_active
from source
