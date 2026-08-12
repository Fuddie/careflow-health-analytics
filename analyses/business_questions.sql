-- 1. Which departments have the highest appointment no-show rate?
select
    department,
    count(appointment_id) as appointments,
    countif(is_no_show) as no_shows,
    safe_divide(countif(is_no_show), count(appointment_id)) as no_show_rate
from {{ ref('fct_appointments') }}
group by department
order by no_show_rate desc;

-- 2. Which facilities have the longest average patient wait time?
select
    facility_id,
    avg(wait_time_minutes) as average_wait_time_minutes,
    count(encounter_id) as encounters
from {{ ref('fct_encounters') }}
group by facility_id
order by average_wait_time_minutes desc;

-- 3. How does 30-day readmission change by discharge month?
select
    discharge_month,
    discharged_admissions,
    readmissions_within_30_days,
    readmission_rate_30d
from {{ ref('mart_readmissions_30d') }}
order by discharge_month;
