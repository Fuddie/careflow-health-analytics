-- Model: mart_readmissions_30d
-- Purpose: Monthly 30-day readmission summary.
-- Grain: One row per discharge_month.
--
-- This is an operational portfolio metric, not a clinical quality claim.
-- Real readmission reporting can require exclusions and risk adjustment.

with discharged_admissions as (
    select
        admission_id,
        patient_id,
        discharge_date,
        is_readmitted_within_30_days
    from {{ ref('fct_admissions') }}
    where discharge_date is not null
)

select
    date_trunc(discharge_date, month) as discharge_month,
    count(admission_id) as discharged_admissions,
    countif(is_readmitted_within_30_days) as readmissions_within_30_days,
    safe_divide(
        countif(is_readmitted_within_30_days),
        count(admission_id)
    ) as readmission_rate_30d
from discharged_admissions
group by discharge_month
order by discharge_month
