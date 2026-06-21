# Face Recognition Accuracy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Supabase-backed face recognition accuracy logging and an admin dashboard page for thesis metrics.

**Architecture:** Flutter records recognition attempts through a small log payload helper and inserts rows into `face_recognition_logs` without blocking attendance. The admin web reads the same table, computes metrics in a pure helper, and renders a new `/accuracy` page from existing client-side Supabase patterns.

**Tech Stack:** Flutter/Dart, Supabase PostgreSQL/RLS, Next.js 16, TypeScript, ESLint.

---

### Task 1: Database Migration

**Files:**
- Create: `supabase/migrations/20260621_create_face_recognition_logs.sql`

- [ ] Create `face_recognition_logs` with columns from the design.
- [ ] Enable RLS and grants for Data API access.
- [ ] Add policies for authenticated insert, own-row read, admin read, and service role access.

### Task 2: Admin Metrics Helper

**Files:**
- Create: `ambis-admin/lib/accuracyMetrics.ts`
- Create: `ambis-admin/lib/accuracyMetrics.test.ts`

- [ ] Write tests for empty metrics, average score, success rate, FRR, and FAR.
- [ ] Implement `computeAccuracyMetrics(rows)`.
- [ ] Verify the tests pass with a lightweight TypeScript test runner.

### Task 3: Admin Accuracy Page

**Files:**
- Modify: `ambis-admin/components/layout/Sidebar.tsx`
- Create: `ambis-admin/app/accuracy/page.tsx`
- Delete: `ambis-admin/app/demo/page.tsx`

- [ ] Replace `Demo Data` sidebar item with `Accuracy`.
- [ ] Build `/accuracy` with cards and recent log table.
- [ ] Remove the demo page file.
- [ ] Run admin lint/build checks.

### Task 4: Flutter Logging

**Files:**
- Modify: `ambis-attendance/lib/features/attendance/data/repositories/attendance_repository.dart`
- Create: `ambis-attendance/test/features/attendance/data/repositories/face_recognition_log_payload_test.dart`

- [ ] Add `buildFaceRecognitionLogPayload`.
- [ ] Write tests for success and failure payloads.
- [ ] Insert logs on successful attendance and failed face mismatch.
- [ ] Keep logging non-blocking.
- [ ] Run Flutter tests/analyze/build checks.
