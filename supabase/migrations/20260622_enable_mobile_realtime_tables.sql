do $$
declare
  realtime_table text;
  realtime_tables text[] := array[
    'attendance',
    'grades',
    'leave_requests',
    'notifications',
    'notification_preferences',
    'users',
    'students',
    'settings'
  ];
begin
  foreach realtime_table in array realtime_tables loop
    if not exists (
      select 1
      from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = realtime_table
    ) then
      execute format(
        'alter publication supabase_realtime add table public.%I',
        realtime_table
      );
    end if;
  end loop;
end $$;
