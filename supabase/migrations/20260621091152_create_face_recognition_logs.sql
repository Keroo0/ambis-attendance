create table if not exists public.face_recognition_logs (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  attendance_id uuid references public.attendance(id) on delete set null,
  attempt_type text not null default 'genuine'
    check (attempt_type in ('genuine', 'impostor')),
  source text not null default 'attendance',
  face_match_score double precision,
  threshold double precision not null,
  passed boolean not null,
  liveness_verified boolean not null default false,
  failure_reason text,
  duration_ms integer,
  created_at bigint not null default (
    extract(epoch from now()) * 1000
  )::bigint
);

create index if not exists face_recognition_logs_student_id_idx
  on public.face_recognition_logs(student_id);

create index if not exists face_recognition_logs_created_at_idx
  on public.face_recognition_logs(created_at desc);

create index if not exists face_recognition_logs_attempt_type_idx
  on public.face_recognition_logs(attempt_type);

alter table public.face_recognition_logs enable row level security;

grant select, insert on table public.face_recognition_logs to authenticated;
grant select, insert, update, delete on table public.face_recognition_logs to service_role;

drop policy if exists "students_insert_own_face_recognition_logs"
  on public.face_recognition_logs;
create policy "students_insert_own_face_recognition_logs"
on public.face_recognition_logs
for insert
to authenticated
with check (student_id = auth.uid());

drop policy if exists "students_read_own_face_recognition_logs"
  on public.face_recognition_logs;
create policy "students_read_own_face_recognition_logs"
on public.face_recognition_logs
for select
to authenticated
using (student_id = auth.uid());

drop policy if exists "admins_read_face_recognition_logs"
  on public.face_recognition_logs;
create policy "admins_read_face_recognition_logs"
on public.face_recognition_logs
for select
to authenticated
using (
  exists (
    select 1
    from public.users u
    where u.id = auth.uid()
      and u.role = 'admin'
  )
);

insert into public.face_recognition_logs (
  student_id,
  attendance_id,
  attempt_type,
  source,
  face_match_score,
  threshold,
  passed,
  liveness_verified,
  failure_reason,
  duration_ms,
  created_at
)
select
  a.student_id,
  a.id,
  'genuine',
  'attendance_backfill',
  a.face_match_score,
  coalesce(
    nullif((select value from public.settings where key = 'face_recognition_threshold'), '')::double precision,
    0.75
  ),
  true,
  coalesce(a.liveness_verified, false),
  null,
  null,
  coalesce(a.updated_at, a.created_at, (extract(epoch from now()) * 1000)::bigint)
from public.attendance a
where a.face_match_score is not null
  and not exists (
    select 1
    from public.face_recognition_logs l
    where l.attendance_id = a.id
      and l.source = 'attendance_backfill'
  );
