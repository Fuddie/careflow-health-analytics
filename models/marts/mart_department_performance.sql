-- Model: mart_department_performance
-- Purpose: Monthly department-level service volume and waiting-time metrics.
-- Grain: One row per activity_month + facility_id + department.

with encounters as (
    select
        encounter_id,
        patient_id,
        facility_id,
        department,
        encounter_date,
        wait_time_minutes,
        consultation_minutes
    from {{ ref('fct_encounters') }}
)

select
    date_trunc(encounter_date, month) as activity_month,
    facility_id,
    department,
    count(encounter_id) as encounters,
    count(distinct patient_id) as unique_patients,
    avg(wait_time_minutes) as average_wait_time_minutes,
    approx_quantiles(wait_time_minutes, 100)[offset(50)] as median_wait_time_minutes,
    avg(consultation_minutes) as average_consultation_minutes
from encounters
group by activity_month, facility_id, department
order by activity_month, facility_id, department
