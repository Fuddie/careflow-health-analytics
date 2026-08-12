# CareFlow Dashboard Specification

The dashboard uses the reporting marts rather than raw healthcare events.

## Main KPI cards

1. **Daily Active Patients** — distinct patients with an encounter on a day.
2. **Monthly Active Patients** — distinct patients with an encounter in a month.
3. **Appointment No-show Rate** — no-show appointments divided by all booked appointments.
4. **Average Wait Time** — average minutes from arrival to consultation start.
5. **Median Wait Time** — median minutes from arrival to consultation start.
6. **Average Consultation Time** — average minutes from consultation start to end.
7. **Average Length of Stay** — average inpatient stay duration in days.
8. **30-Day Readmission Rate** — discharged admissions followed by another admission within 30 days, divided by discharged admissions.
9. **Bed Occupancy Rate** — occupied beds divided by licensed beds.
10. **Monthly Patient Return Rate** — patients active in both the current and previous month divided by previous-month active patients.

## Recommended visuals

### Appointment operations
- Appointment volume by day and department
- Completed, no-show and cancelled appointment mix
- No-show rate by department and facility

### Patient flow
- Daily active patients
- Average and median wait time trend
- Wait time by department

### Inpatient operations
- Average length of stay by department
- Bed occupancy by facility and day
- Monthly 30-day readmission rate

### Patient engagement
- Monthly active patients
- Returning patients
- Monthly patient return rate

## Synthetic benchmark

The deterministic dataset used for the project contains:

- **400 patients**
- **5 facilities**
- **40 clinicians**
- **2,500 appointments**
- **1,818 encounters**
- **309 admissions**
- **13.16% appointment no-show rate**
- **44.15 minutes average wait time**
- **4.83 days average length of stay**
- **20.39% synthetic 30-day readmission rate**

Monthly active patients range from **199 to 225** across January to June 2026.

All figures are synthetic and exist only to demonstrate healthcare analytics engineering and dashboard design.
