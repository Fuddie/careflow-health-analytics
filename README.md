# CareFlow Health Analytics

CareFlow is a personal analytics engineering project for a fictional healthcare provider. It uses synthetic appointment, encounter, admission, clinician, facility and patient data to build tested reporting models with **dbt, BigQuery SQL and Python**.

All data in this repository is synthetic. No real patient, hospital or employer data is used.

## Project scope

The project focuses on operational healthcare analytics rather than diagnosis or clinical prediction. It models scheduling, patient flow, inpatient activity, facility capacity and patient return patterns.

It supports questions such as:

- What is the appointment no-show rate?
- How long do patients wait before consultation?
- Which departments have the highest patient volume?
- What is the average inpatient length of stay?
- What percentage of discharged patients are readmitted within 30 days?
- How heavily are licensed beds being used?
- How many patients are active each month?
- What percentage of last month's patients return this month?

## Technology

- **dbt**: transformations, tests and documentation
- **Google BigQuery**: warehouse design and SQL
- **Python**: deterministic synthetic data generation
- **dbt_utils**: range and composite-grain tests

## Model structure

```text
raw patients / facilities / clinicians / appointments / encounters / admissions
                                  │
                                  ▼
                             staging models
                                  │
                    ┌─────────────┴─────────────┐
                    ▼                           ▼
       appointment outcome logic      admission sequence logic
                    │                           │
                    └─────────────┬─────────────┘
                                  ▼
                    facts + dimensions
                                  │
                                  ▼
     daily care KPIs / patient engagement / department performance
            readmissions / bed occupancy
```

## Main models

### `fct_appointments`
One row per appointment with status flags for completed, no-show and cancelled bookings. The model uses incremental MERGE logic with a three-day lookback.

### `fct_encounters`
One row per completed encounter with patient waiting time and consultation duration.

### `fct_admissions`
One row per admission with length of stay and a 30-day readmission flag based on the patient's next admission.

### `mart_daily_care_kpis`
Daily appointment volume, no-show rate, encounter volume, active patients and wait-time measures.

### `mart_monthly_patient_engagement`
Monthly active patients, returning patients and month-over-month return rate.

### `mart_department_performance`
Monthly department-level encounter volume, unique patients, wait time and consultation time.

### `mart_readmissions_30d`
Monthly discharged admissions, 30-day readmissions and readmission rate.

### `mart_bed_occupancy_daily`
Daily occupied beds, licensed beds and bed occupancy rate by facility.

## Data quality

Tests cover:

- unique and non-null business keys
- appointment status values
- source relationships
- non-negative waiting time
- positive consultation duration
- discharge after admission
- readmission timestamp consistency
- returning patients not exceeding the previous-month patient population
- occupied beds not exceeding licensed capacity
- percentage metrics remaining between 0 and 1
- explicit SQL column selection rather than `SELECT *`

## Dashboard KPIs

The dashboard layer includes:

- Daily Active Patients
- Monthly Active Patients
- Appointment No-show Rate
- Average Wait Time
- Median Wait Time
- Average Consultation Time
- Average Length of Stay
- 30-Day Readmission Rate
- Bed Occupancy Rate
- Monthly Patient Return Rate

See [`dashboard/README.md`](dashboard/README.md) for definitions and suggested visuals.

## Running the project

1. Install dbt for BigQuery.
2. Copy `profiles.example.yml` to the local dbt profiles directory and replace the placeholders.
3. Run `dbt deps`.
4. Generate the deterministic synthetic source files with `python scripts/generate_sample_data.py`.
5. Run `dbt seed`.
6. Run `dbt build`.
7. Run `dbt docs generate` and `dbt docs serve` if local documentation is required.

## Documentation

- [Architecture](docs/architecture.md)
- [Technical notes](docs/technical_notes.md)
- [Dashboard specification](dashboard/README.md)

## Author

**Fuad Abiola Adebisi**  
Analytics Engineer  
[GitHub](https://github.com/Fuddie)
