-- Model: fct_appointments
-- Purpose: Appointment fact table for scheduling, attendance and no-show reporting.
-- Grain: One row per appointment_id.
--
-- Incremental logic re-reads a small recent-history window so delayed appointment
-- updates can be merged without rebuilding the full table.

{{
    config(
        materialized='incremental',
        unique_key='appointment_id',
        incremental_strategy='merge',
        partition_by={'field': 'appointment_date', 'data_type': 'date'},
        cluster_by=['facility_id', 'department', 'appointment_status'],
        on_schema_change='fail'
    )
}}

with appointments as (
    select
        appointment_id,
        patient_id,
        clinician_id,
        facility_id,
        department,
        scheduled_at,
        booked_at,
        appointment_status,
        arrival_at,
        appointment_date,
        is_completed,
        is_no_show,
        is_cancelled,
        booking_lead_hours
    from {{ ref('int_appointment_outcomes') }}

    {% if is_incremental() %}
        -- Re-read recent scheduled records so late status updates can still be merged.
        where scheduled_at >= timestamp_sub(
            (
                select coalesce(max(scheduled_at), timestamp('1900-01-01'))
                from {{ this }}
            ),
            interval {{ var('incremental_lookback_days', 3) }} day
        )
    {% endif %}
)

select
    appointment_id,
    patient_id,
    clinician_id,
    facility_id,
    department,
    scheduled_at,
    booked_at,
    appointment_status,
    arrival_at,
    appointment_date,
    is_completed,
    is_no_show,
    is_cancelled,
    booking_lead_hours
from appointments
