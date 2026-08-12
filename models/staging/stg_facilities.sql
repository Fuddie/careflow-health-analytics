-- Model: stg_facilities
-- Purpose: Standardise facility attributes and licensed bed capacity.
-- Grain: One row per facility_id.

with source as (
    select
        facility_id,
        facility_name,
        city,
        licensed_beds,
        facility_type
    from {{ source('careflow_raw', 'raw_facilities') }}
)

select
    cast(facility_id as string) as facility_id,
    trim(facility_name) as facility_name,
    trim(city) as city,
    cast(licensed_beds as int64) as licensed_beds,
    upper(trim(facility_type)) as facility_type
from source
