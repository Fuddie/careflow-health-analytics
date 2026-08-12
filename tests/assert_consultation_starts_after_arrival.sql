-- Test: consultation cannot begin before the recorded patient arrival time.
-- A returned row indicates a timing-order defect.

select
    encounter_id,
    arrival_at,
    consultation_start_at
from {{ ref('fct_encounters') }}
where consultation_start_at < arrival_at
