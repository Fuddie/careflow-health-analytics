-- Model: dim_clinicians
-- Purpose: Clinician dimension for department and facility reporting.
-- Grain: One row per clinician_id.

select
    clinician_id,
    department,
    role,
    facility_id,
    active_from,
    active_to
from {{ ref('stg_clinicians') }}
