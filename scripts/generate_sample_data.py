"""Generate deterministic synthetic CareFlow source data.

All records are fictional. No real patient, clinician, hospital or employer data is used.
"""

from pathlib import Path
from datetime import date, datetime, timedelta
import csv
import random

SEED = 42
ADMISSION_SEED = 84
ROOT = Path(__file__).resolve().parents[1]
SEED_DIR = ROOT / "seeds"
SEED_DIR.mkdir(parents=True, exist_ok=True)
START_DATE = date(2026, 1, 1)
END_DATE = date(2026, 6, 30)
DATE_SPAN = (END_DATE - START_DATE).days

DEPARTMENTS = [
    "General Medicine", "Paediatrics", "Obstetrics & Gynaecology",
    "Cardiology", "Orthopaedics", "ENT", "Dermatology", "Emergency"
]
FACILITIES = [
    ("F001", "CareFlow Central Hospital", "Lagos", 120),
    ("F002", "CareFlow Mainland Clinic", "Lagos", 60),
    ("F003", "CareFlow Abuja Centre", "Abuja", 80),
    ("F004", "CareFlow Ibadan Clinic", "Ibadan", 50),
    ("F005", "CareFlow Port Harcourt Centre", "Port Harcourt", 70),
]


def write_csv(name, rows):
    with (SEED_DIR / name).open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def build_core_data():
    rng = random.Random(SEED)
    states = ["LA", "AB", "OG", "OY", "RI", "KD", "EN", "AN", "DE", "ED"]
    payer_types = ["SELF_PAY", "PRIVATE_INSURANCE", "HMO"]

    patients = []
    for i in range(1, 401):
        dob = date(rng.randint(1945, 2016), rng.randint(1, 12), rng.randint(1, 28))
        patients.append({
            "patient_id": f"P{i:04d}",
            "date_of_birth": dob.isoformat(),
            "sex": rng.choice(["F", "M"]),
            "state": rng.choice(states),
            "payer_type": rng.choices(payer_types, weights=[0.42, 0.23, 0.35], k=1)[0],
            "registration_date": (START_DATE - timedelta(days=rng.randint(15, 900))).isoformat(),
            "is_active": "true" if rng.random() < 0.95 else "false",
        })

    facilities = [
        {
            "facility_id": facility_id,
            "facility_name": name,
            "city": city,
            "licensed_beds": beds,
            "facility_type": "Hospital" if beds >= 80 else "Clinic",
        }
        for facility_id, name, city, beds in FACILITIES
    ]

    clinicians = []
    roles = ["Consultant", "Medical Officer", "Nurse Practitioner"]
    for i in range(1, 41):
        clinicians.append({
            "clinician_id": f"C{i:03d}",
            "department": DEPARTMENTS[(i - 1) % len(DEPARTMENTS)],
            "role": rng.choices(roles, weights=[0.35, 0.50, 0.15], k=1)[0],
            "facility_id": rng.choice(FACILITIES)[0],
            "active_from": (START_DATE - timedelta(days=rng.randint(60, 1500))).isoformat(),
            "active_to": "",
        })

    appointments = []
    for i in range(1, 2501):
        appt_date = START_DATE + timedelta(days=rng.randint(0, DATE_SPAN))
        scheduled = datetime(
            appt_date.year, appt_date.month, appt_date.day,
            rng.randint(8, 16), rng.choice([0, 15, 30, 45])
        )
        clinician = rng.choice(clinicians)
        status = rng.choices(
            ["COMPLETED", "NO_SHOW", "CANCELLED"],
            weights=[0.77, 0.13, 0.10], k=1
        )[0]
        booked = scheduled - timedelta(days=rng.randint(0, 30), hours=rng.randint(1, 8))
        arrival = ""
        if status == "COMPLETED":
            arrival = (scheduled + timedelta(minutes=rng.randint(-20, 35))).isoformat(sep=" ")
        appointments.append({
            "appointment_id": f"A{i:05d}",
            "patient_id": rng.choice(patients)["patient_id"],
            "clinician_id": clinician["clinician_id"],
            "facility_id": clinician["facility_id"],
            "department": clinician["department"],
            "scheduled_at": scheduled.isoformat(sep=" "),
            "booked_at": booked.isoformat(sep=" "),
            "appointment_status": status,
            "arrival_at": arrival,
        })

    encounters = []
    encounter_id = 1
    for appointment in appointments:
        if appointment["appointment_status"] != "COMPLETED" or rng.random() > 0.94:
            continue
        scheduled = datetime.fromisoformat(appointment["scheduled_at"])
        arrival = datetime.fromisoformat(appointment["arrival_at"])
        start = max(scheduled, arrival) + timedelta(minutes=rng.randint(5, 75))
        end = start + timedelta(minutes=rng.randint(10, 55))
        encounters.append({
            "encounter_id": f"E{encounter_id:05d}",
            "appointment_id": appointment["appointment_id"],
            "patient_id": appointment["patient_id"],
            "clinician_id": appointment["clinician_id"],
            "facility_id": appointment["facility_id"],
            "department": appointment["department"],
            "encounter_type": "EMERGENCY" if appointment["department"] == "Emergency" else rng.choices(["OUTPATIENT", "FOLLOW_UP"], [0.78, 0.22], k=1)[0],
            "arrival_at": arrival.isoformat(sep=" "),
            "consultation_start_at": start.isoformat(sep=" "),
            "consultation_end_at": end.isoformat(sep=" "),
        })
        encounter_id += 1

    return patients, facilities, clinicians, appointments, encounters


def build_admissions(patients, facilities):
    rng = random.Random(ADMISSION_SEED)
    patient_ids = [p["patient_id"] for p in patients]
    admissions = []
    admission_id = 1

    for _ in range(280):
        patient_id = rng.choice(patient_ids)
        admit_date = START_DATE + timedelta(days=rng.randint(0, DATE_SPAN - 10))
        admitted = datetime(admit_date.year, admit_date.month, admit_date.day, rng.randint(0, 23), rng.randint(0, 59))
        los_days = rng.choices([1,2,3,4,5,6,7,8,9,10], weights=[8,15,20,18,12,8,6,5,4,4], k=1)[0]
        discharged = admitted + timedelta(days=los_days, hours=rng.randint(0, 12))
        facility = rng.choice(facilities)
        department = rng.choice(["General Medicine", "Paediatrics", "Cardiology", "Orthopaedics", "Obstetrics & Gynaecology"])
        admissions.append({
            "admission_id": f"ADM{admission_id:04d}",
            "patient_id": patient_id,
            "facility_id": facility["facility_id"],
            "department": department,
            "admitted_at": admitted.isoformat(sep=" "),
            "discharged_at": discharged.isoformat(sep=" "),
            "discharge_disposition": rng.choices(["HOME", "TRANSFER", "LEFT_AGAINST_ADVICE"], [0.91, 0.06, 0.03], k=1)[0],
        })
        admission_id += 1

    eligible = [a for a in admissions if datetime.fromisoformat(a["discharged_at"]).date() <= END_DATE - timedelta(days=7)]
    rng.shuffle(eligible)
    for prior in eligible[:30]:
        prior_discharge = datetime.fromisoformat(prior["discharged_at"])
        admitted = prior_discharge + timedelta(days=rng.randint(3, 28), hours=rng.randint(1, 12))
        if admitted.date() > END_DATE:
            continue
        discharged = min(
            admitted + timedelta(days=rng.randint(1, 6), hours=rng.randint(0, 10)),
            datetime(END_DATE.year, END_DATE.month, END_DATE.day, 23, 59)
        )
        facility = rng.choice(facilities)
        admissions.append({
            "admission_id": f"ADM{admission_id:04d}",
            "patient_id": prior["patient_id"],
            "facility_id": facility["facility_id"],
            "department": prior["department"],
            "admitted_at": admitted.isoformat(sep=" "),
            "discharged_at": discharged.isoformat(sep=" "),
            "discharge_disposition": rng.choices(["HOME", "TRANSFER", "LEFT_AGAINST_ADVICE"], [0.92, 0.05, 0.03], k=1)[0],
        })
        admission_id += 1

    admissions.sort(key=lambda row: (row["patient_id"], row["admitted_at"]))
    return admissions


def main():
    patients, facilities, clinicians, appointments, encounters = build_core_data()
    admissions = build_admissions(patients, facilities)
    write_csv("raw_patients.csv", patients)
    write_csv("raw_facilities.csv", facilities)
    write_csv("raw_clinicians.csv", clinicians)
    write_csv("raw_appointments.csv", appointments)
    write_csv("raw_encounters.csv", encounters)
    write_csv("raw_admissions.csv", admissions)
    print(f"Generated {len(patients)} patients, {len(facilities)} facilities, {len(clinicians)} clinicians, {len(appointments)} appointments, {len(encounters)} encounters and {len(admissions)} admissions.")


if __name__ == "__main__":
    main()
