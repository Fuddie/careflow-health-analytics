-- Test: every discharge must occur after its admission.
-- A returned row indicates an invalid inpatient interval.

select
    admission_id,
    admitted_at,
    discharged_at
from {{ ref('fct_admissions') }}
where discharged_at <= admitted_at
