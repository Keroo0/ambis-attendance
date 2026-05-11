-- ============================================================
-- Migration: Seed dummy grades + homeroom_teacher for NISN 9999000001
-- ============================================================

-- 1. Tambah kolom homeroom_teacher ke tabel students (jika belum ada)
ALTER TABLE students ADD COLUMN IF NOT EXISTS homeroom_teacher TEXT;

-- 2. Pastikan status aktif dummy student = true
UPDATE users
SET is_active = TRUE
WHERE nisn = '9999000001';

-- 3. Set homeroom teacher untuk dummy student
UPDATE students
SET homeroom_teacher = 'Drs. Budi Santoso, M.Pd.'
WHERE nisn = '9999000001';

-- 4. Seed dummy grades untuk NISN 9999000001 (semester 1 & 2)
DO $$
DECLARE
  v_student_id UUID;
BEGIN
  SELECT id INTO v_student_id FROM users WHERE nisn = '9999000001';

  IF v_student_id IS NULL THEN
    RAISE NOTICE 'Student dengan NISN 9999000001 tidak ditemukan, skip seed grades.';
    RETURN;
  END IF;

  -- Hapus grades lama agar tidak duplikat
  DELETE FROM grades WHERE student_id = v_student_id;

  -- ── Semester 1 (Ganjil) ───────────────────────────────────────────
  INSERT INTO grades (id, student_id, subject, type, score, semester, year, created_at, updated_at) VALUES
    (gen_random_uuid(), v_student_id, 'Matematika',        'UTS',   82, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Matematika',        'UAS',   78, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Matematika',        'tugas', 80, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Bahasa Indonesia',  'UTS',   88, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Bahasa Indonesia',  'UAS',   85, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Bahasa Indonesia',  'tugas', 90, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Bahasa Inggris',    'UTS',   79, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Bahasa Inggris',    'UAS',   83, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Bahasa Inggris',    'tugas', 85, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Fisika',            'UTS',   76, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Fisika',            'UAS',   74, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Fisika',            'tugas', 78, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Kimia',             'UTS',   80, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Kimia',             'UAS',   77, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Kimia',             'tugas', 82, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Biologi',           'UTS',   85, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Biologi',           'UAS',   82, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Biologi',           'tugas', 87, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Sejarah',           'UTS',   90, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Sejarah',           'UAS',   87, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Sejarah',           'tugas', 88, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Pendidikan Agama',  'UTS',   92, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Pendidikan Agama',  'UAS',   90, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Pendidikan Agama',  'tugas', 93, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'PJOK',              'UTS',   88, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'PJOK',              'UAS',   85, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'PJOK',              'tugas', 90, 1, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000);

  -- ── Semester 2 (Genap) ────────────────────────────────────────────
  INSERT INTO grades (id, student_id, subject, type, score, semester, year, created_at, updated_at) VALUES
    (gen_random_uuid(), v_student_id, 'Matematika',        'UTS',   84, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Matematika',        'UAS',   81, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Matematika',        'tugas', 83, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Bahasa Indonesia',  'UTS',   90, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Bahasa Indonesia',  'UAS',   87, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Bahasa Indonesia',  'tugas', 91, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Bahasa Inggris',    'UTS',   81, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Bahasa Inggris',    'UAS',   85, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Bahasa Inggris',    'tugas', 87, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Fisika',            'UTS',   78, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Fisika',            'UAS',   76, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Fisika',            'tugas', 80, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Kimia',             'UTS',   82, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Kimia',             'UAS',   79, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Kimia',             'tugas', 84, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Biologi',           'UTS',   87, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Biologi',           'UAS',   84, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Biologi',           'tugas', 89, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Sejarah',           'UTS',   91, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Sejarah',           'UAS',   88, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Sejarah',           'tugas', 90, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'Pendidikan Agama',  'UTS',   94, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Pendidikan Agama',  'UAS',   91, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'Pendidikan Agama',  'tugas', 95, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),

    (gen_random_uuid(), v_student_id, 'PJOK',              'UTS',   90, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'PJOK',              'UAS',   87, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000),
    (gen_random_uuid(), v_student_id, 'PJOK',              'tugas', 92, 2, 2025, extract(epoch from now())::bigint * 1000, extract(epoch from now())::bigint * 1000);

  RAISE NOTICE 'Berhasil seed % grades untuk NISN 9999000001.', 54;
END $$;
