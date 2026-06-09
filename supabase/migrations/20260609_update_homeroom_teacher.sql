-- ============================================================
-- Migration: Update homeroom_teacher per kelas
-- Jalankan di Supabase > SQL Editor
-- Ganti nama wali kelas sesuai data asli
-- ============================================================

-- Pastikan kolom sudah ada
ALTER TABLE students ADD COLUMN IF NOT EXISTS homeroom_teacher TEXT;

-- ── Kelas X ──────────────────────────────────────────────────
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas X IPA 1' WHERE class = 'X IPA 1';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas X IPA 2' WHERE class = 'X IPA 2';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas X IPA 3' WHERE class = 'X IPA 3';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas X IPS 1' WHERE class = 'X IPS 1';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas X IPS 2' WHERE class = 'X IPS 2';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas X IPS 3' WHERE class = 'X IPS 3';

-- ── Kelas XI ─────────────────────────────────────────────────
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XI IPA 1' WHERE class = 'XI IPA 1';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XI IPA 2' WHERE class = 'XI IPA 2';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XI IPA 3' WHERE class = 'XI IPA 3';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XI IPS 1' WHERE class = 'XI IPS 1';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XI IPS 2' WHERE class = 'XI IPS 2';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XI IPS 3' WHERE class = 'XI IPS 3';

-- ── Kelas XII ────────────────────────────────────────────────
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XII IPA 1' WHERE class = 'XII IPA 1';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XII IPA 2' WHERE class = 'XII IPA 2';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XII IPA 3' WHERE class = 'XII IPA 3';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XII IPS 1' WHERE class = 'XII IPS 1';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XII IPS 2' WHERE class = 'XII IPS 2';
UPDATE students SET homeroom_teacher = 'Nama Wali Kelas XII IPS 3' WHERE class = 'XII IPS 3';

-- ── Cek hasil ────────────────────────────────────────────────
-- Jalankan ini untuk verifikasi setelah update:
-- SELECT class, homeroom_teacher, COUNT(*) as jumlah_siswa
-- FROM students
-- GROUP BY class, homeroom_teacher
-- ORDER BY class;
