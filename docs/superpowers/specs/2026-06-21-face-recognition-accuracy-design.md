# Face Recognition Accuracy Design

## Goal

Add thesis-ready face recognition evaluation data by logging attendance recognition attempts and showing aggregate accuracy metrics in the admin web dashboard.

## Scope

- Create a Supabase table `face_recognition_logs`.
- Log Flutter attendance recognition attempts from `AttendanceRepository`.
- Add an admin web page `/accuracy` with summary cards and recent logs.
- Replace the old `Demo Data` sidebar item with `Accuracy`.
- Remove the admin demo page because it is no longer needed.

## Data Model

`face_recognition_logs` stores one row per recognition attempt:

- `id uuid primary key`
- `student_id uuid references students(id)`
- `attendance_id uuid references attendance(id)`
- `attempt_type text default 'genuine'`
- `source text default 'attendance'`
- `face_match_score double precision`
- `threshold double precision`
- `passed boolean`
- `liveness_verified boolean`
- `failure_reason text`
- `duration_ms integer`
- `created_at bigint`

Normal student attendance attempts are logged as `genuine`. FAR becomes meaningful when thesis testing inserts or produces `impostor` attempts.

## Admin Metrics

The admin page computes:

- average face match score
- total attempts
- passed and failed attempts
- liveness success rate
- FRR from failed `genuine` attempts
- FAR from passed `impostor` attempts

Rows with no score are kept for operational diagnostics but excluded from average score.

## Security

The table has RLS enabled. Authenticated users can insert logs and read their own rows; admin users can read all rows. Service role keeps full access for admin/server use.

## Testing

- Add a pure TypeScript metrics helper with unit tests for average score, success rate, FRR, FAR, and empty state.
- Add a Dart unit test for the log payload helper.
- Run lint/build/analyze commands after implementation.
