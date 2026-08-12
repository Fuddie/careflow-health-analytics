-- Model: mart_daily_care_kpis
-- Purpose: Daily operational KPIs for appointments, encounters and wait time.
-- Grain: One row per reporting_date.

with appointment_daily as (
    select
        appointment_date as reporting_date,
        count(appointment_id) as appointments_booked,
        countif(is_completed) as completed_appointments,
        countif(is_no_show) as no_show_appointments,
        countif(is_cancelled) as cancelled_appointments,
        safe_divide(countif(is_no_show), count(appointment_id)) as no_show_rate
    from {{ ref('fct_appointments') }}
    group by appointment_date
),

encounter_daily as (
    select
        encounter_date as reporting_date,
        count(encounter_id) as encounters,
        count(distinct patient_id) as daily_active_patients,
        avg(wait_time_minutes) as average_wait_time_minutes,
        approx_quantiles(wait_time_minutes, 100)[offset(50)] as median_wait_time_minutes,
        avg(consultation_minutes) as average_consultation_minutes
    from {{ ref('fct_encounters') }}
    group by encounter_date
)

select
    coalesce(a.reporting_date, e.reporting_date) as reporting_date,
    coalesce(a.appointments_booked, 0) as appointments_booked,
    coalesce(a.completed_appointments, 0) as completed_appointments,
    coalesce(a.no_show_appointments, 0) as no_show_appointments,
    coalesce(a.cancelled_appointments, 0) as cancelled_appointments,
    a.no_show_rate,
    coalesce(e.encounters, 0) as encounters,
    coalesce(e.daily_active_patients, 0) as daily_active_patients,
    e.average_wait_time_minutes,
    e.median_wait_time_minutes,
    e.average_consultation_minutes
from appointment_daily as a
full outer join encounter_daily as e
    on a.reporting_date = e.reporting_date
order by reporting_date
