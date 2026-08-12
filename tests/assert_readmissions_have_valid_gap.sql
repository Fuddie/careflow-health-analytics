-- Test: records flagged as 30-day readmissions must have a next admission
-- between 0 and 30 days after discharge.
-- A returned row means the readmission flag and timestamps disagree.

select
    admission_id,
    discharged_at,
    next_admitted_at,
    is_readmitted_within_30_days
from {{ ref('fct_admissions') }}
where is_readmitted_within_30_days
  and (
      next_admitted_at is null
      or timestamp_diff(next_admitted_at, discharged_at, day) not between 0 and 30
  )
