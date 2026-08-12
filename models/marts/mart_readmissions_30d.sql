-- Model: mart_readmissions_30d
-- Purpose: Monthly 30-day readmission summary.
-- Grain: One row per discharge_month.
--
-- Only discharges with a complete 30-day follow-up window are included in the
-- denominator. This prevents recent discharges near the end of the dataset from
-- being incorrectly treated as non-readmissions before 30 days have elapsed.
--
-- This remains an operational portfolio metric, not a clinical quality claim.
-- Real readmission reporting can require exclusions and risk adjustment.

with observation_window as (
    select
        max(discharge_date) as observation_end_date
    from {{ ref('fct_admissions') }}
),

eligible_discharges as (
    select
        a.admission_id,
        a.patient_id,
        a.discharge_date,
        a.is_readmitted_within_30_days
    from {{ ref('fct_admissions') }} as a
    cross join observation_window as w
    where a.discharge_date is not null
      and a.discharge_date <= date_sub(w.observation_end_date, interval 30 day)
)

select
    date_trunc(discharge_date, month) as discharge_month,
    count(admission_id) as eligible_discharged_admissions,
    countif(is_readmitted_within_30_days) as readmissions_within_30_days,
    safe_divide(
        countif(is_readmitted_within_30_days),
        count(admission_id)
    ) as readmission_rate_30d
from eligible_discharges
group by discharge_month
order by discharge_month
