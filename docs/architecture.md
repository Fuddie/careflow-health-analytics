# CareFlow Architecture

CareFlow separates source cleanup, reusable logic and reporting outputs.

## Sources

Synthetic raw tables:

- `raw_patients`
- `raw_facilities`
- `raw_clinicians`
- `raw_appointments`
- `raw_encounters`
- `raw_admissions`

## Staging

Staging models standardise data types, casing and identifiers while keeping the source grain.

## Intermediate

- `int_appointment_outcomes` centralises attendance flags and booking timing.
- `int_admission_sequence` orders each patient's admissions and identifies the next admission.

## Facts and dimensions

- `fct_appointments`
- `fct_encounters`
- `fct_admissions`
- `dim_patients`
- `dim_clinicians`
- `dim_facilities`

## Reporting marts

- `mart_daily_care_kpis`
- `mart_monthly_patient_engagement`
- `mart_department_performance`
- `mart_readmissions_30d`
- `mart_bed_occupancy_daily`

The reporting layer keeps metric logic in SQL models instead of rebuilding it independently in each dashboard.
