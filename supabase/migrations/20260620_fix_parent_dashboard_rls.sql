-- ============================================================================
-- Fix parent dashboard reads for linked child data.
--
-- Remote evidence:
-- - students.parent_id is linked to the parent user.
-- - users.fullname exists for the child user.
-- - grades rows exist for the same child id.
--
-- Remote already has:
-- - all required columns
-- - RLS enabled
-- - authenticated SELECT grants
-- - parent policy for public.students via "ortu_child_select"
-- - indexes for parent_id / student_id lookups
--
-- The missing surface was parent SELECT access to child rows in related
-- tables. The helper lives in a private schema and runs as SECURITY DEFINER so
-- policy checks can read students without recursively invoking students/users
-- RLS policies.
-- ============================================================================

create schema if not exists private;

revoke all on schema private from public;
grant usage on schema private to authenticated;

create or replace function private.is_parent_of_student(child_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.students s
    where s.id = child_user_id
      and s.parent_id = auth.uid()
  );
$$;

revoke all on function private.is_parent_of_student(uuid) from public;
grant execute on function private.is_parent_of_student(uuid) to authenticated;

-- Parent can read the linked child user row, so the app can display fullname.
drop policy if exists "parent_dashboard_read_child_user" on public.users;
create policy "parent_dashboard_read_child_user"
on public.users
for select
to authenticated
using (private.is_parent_of_student(public.users.id));

-- Parent can read grades for the linked child.
drop policy if exists "parent_dashboard_read_child_grades" on public.grades;
create policy "parent_dashboard_read_child_grades"
on public.grades
for select
to authenticated
using (private.is_parent_of_student(public.grades.student_id));

-- Parent can read attendance for the linked child.
drop policy if exists "parent_dashboard_read_child_attendance" on public.attendance;
create policy "parent_dashboard_read_child_attendance"
on public.attendance
for select
to authenticated
using (private.is_parent_of_student(public.attendance.student_id));

-- Parent can read leave requests for the linked child.
drop policy if exists "parent_dashboard_read_child_leave_requests" on public.leave_requests;
create policy "parent_dashboard_read_child_leave_requests"
on public.leave_requests
for select
to authenticated
using (private.is_parent_of_student(public.leave_requests.student_id));
