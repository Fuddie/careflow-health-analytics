-- Test: returning patients cannot exceed the previous month's active population.
-- A returned row indicates an invalid return-rate calculation.

select
    activity_month,
    previous_month_active_patients,
    returning_patients
from {{ ref('mart_monthly_patient_engagement') }}
where previous_month_active_patients is not null
  and returning_patients > previous_month_active_patients
