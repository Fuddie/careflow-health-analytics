-- Model: mart_monthly_patient_engagement
-- Purpose: Monthly patient activity and return-rate reporting.
-- Grain: One row per activity_month.

with patient_months as (
    select distinct
        date_trunc(encounter_date, month) as activity_month,
        patient_id
    from {{ ref('fct_encounters') }}
),

monthly_active as (
    select
        activity_month,
        count(distinct patient_id) as monthly_active_patients
    from patient_months
    group by activity_month
),

returning as (
    select
        current_month.activity_month,
        count(distinct current_month.patient_id) as returning_patients
    from patient_months as current_month
    inner join patient_months as previous_month
        on current_month.patient_id = previous_month.patient_id
        and previous_month.activity_month = date_sub(current_month.activity_month, interval 1 month)
    group by current_month.activity_month
),

previous_population as (
    select
        current_month.activity_month,
        previous_month.monthly_active_patients as previous_month_active_patients
    from monthly_active as current_month
    left join monthly_active as previous_month
        on previous_month.activity_month = date_sub(current_month.activity_month, interval 1 month)
)

select
    m.activity_month,
    m.monthly_active_patients,
    p.previous_month_active_patients,
    coalesce(r.returning_patients, 0) as returning_patients,

    -- Return rate compares consecutive-month patients with the prior month's population.
    safe_divide(
        coalesce(r.returning_patients, 0),
        p.previous_month_active_patients
    ) as monthly_return_rate
from monthly_active as m
left join returning as r
    on m.activity_month = r.activity_month
left join previous_population as p
    on m.activity_month = p.activity_month
order by m.activity_month
