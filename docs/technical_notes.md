# Technical Notes

## Synthetic data

All records are generated locally with fixed random seeds. The project contains no real patient, clinician, facility, hospital or employer data.

## Appointment modelling

Appointments and encounters are modelled separately because a booked appointment does not always result in a completed encounter. This keeps scheduling outcomes such as no-shows and cancellations separate from consultation activity.

## Waiting time

`wait_time_minutes` is defined as consultation start minus patient arrival. Negative waits are rejected by a singular test.

## Readmission logic

For each admission, the next admission for the same patient is identified with a window function. A 30-day readmission flag is set when the next admission starts between 0 and 30 days after discharge.

The monthly readmission mart only includes discharges with a complete 30-day follow-up window. This avoids treating recent discharges near the end of the dataset as non-readmissions before the full observation period has elapsed.

This is an operational demonstration only. Real clinical readmission measures may require diagnosis-specific exclusions, planned-admission exclusions, risk adjustment and other rules.

## Bed occupancy

Each admission is expanded across the calendar dates on which the patient occupied a bed. Daily occupied beds are divided by the facility's licensed bed capacity.

## Incremental appointments

`fct_appointments` uses a three-day lookback during incremental builds and merges on `appointment_id`. This allows recent delayed appointment updates to be reprocessed without duplicating records.

## Reproducible age bands

Patient age bands are calculated as of the synthetic dataset end date, 30 June 2026, rather than the current date. This keeps model outputs stable when the project is run later.

## SQL convention

Transformation and test queries use explicit column selection. `SELECT *` is intentionally avoided.
