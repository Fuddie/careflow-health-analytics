-- Model: dim_facilities
-- Purpose: Facility dimension including licensed bed capacity.
-- Grain: One row per facility_id.

select
    facility_id,
    facility_name,
    city,
    licensed_beds,
    facility_type
from {{ ref('stg_facilities') }}
