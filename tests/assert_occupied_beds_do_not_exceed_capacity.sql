-- Test: occupied beds should not exceed licensed bed capacity in this synthetic model.
-- A returned row means the occupancy calculation or source capacity is inconsistent.

select
    occupancy_date,
    facility_id,
    licensed_beds,
    occupied_beds
from {{ ref('mart_bed_occupancy_daily') }}
where occupied_beds > licensed_beds
