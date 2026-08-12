-- Model: mart_bed_occupancy_daily
-- Purpose: Estimate daily bed occupancy from inpatient admission intervals.
-- Grain: One row per occupancy_date + facility_id.
--
-- Each admission is expanded to the calendar dates on which the patient occupied a bed.
-- For this project, the discharge date is included as an occupied day.

with admission_days as (
    select
        admission_id,
        facility_id,
        occupancy_date
    from {{ ref('fct_admissions') }},
    unnest(generate_date_array(admission_date, discharge_date)) as occupancy_date
),

occupied as (
    select
        occupancy_date,
        facility_id,
        count(distinct admission_id) as occupied_beds
    from admission_days
    group by occupancy_date, facility_id
),

facilities as (
    select
        facility_id,
        licensed_beds
    from {{ ref('dim_facilities') }}
)

select
    o.occupancy_date,
    o.facility_id,
    f.licensed_beds,
    o.occupied_beds,
    safe_divide(o.occupied_beds, f.licensed_beds) as bed_occupancy_rate
from occupied as o
inner join facilities as f
    on o.facility_id = f.facility_id
order by o.occupancy_date, o.facility_id
