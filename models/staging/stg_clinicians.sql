-- Model: stg_clinicians
-- Purpose: Standardise clinician roster data.
-- Grain: One row per clinician_id.

with source as (
    select
        clinician_id,
        department,
        role,
        facility_id,
        active_from,
        active_to
    from {{ source('careflow_raw', 'raw_clinicians') }}
)

select
    cast(clinician_id as string) as clinician_id,
    trim(department) as department,
    upper(trim(role)) as role,
    cast(facility_id as string) as facility_id,
    cast(active_from as date) as active_from,
    cast(nullif(active_to, '') as date) as active_to
from source
