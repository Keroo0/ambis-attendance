# AMBIS — Progress Handoff

> Dokumen ini dibuat untuk melanjutkan sesi ke sesi baru.
> **Tanggal:** 2026-05-19
> **State:** `flutter analyze` → 0 issues, `npx tsc --noEmit` → 0 errors

---

## Ringkasan Proyek

**AMBIS** (Absensi Biometrik Siswa) adalah sistem presensi berbasis wajah untuk SMAN 07 Kab. Tangerang, terdiri dari:

1. **Flutter App** (`/ambis_attendance`) — mobile app untuk siswa & orang tua
2. **Next.js Web** (`/web`) — dashboard admin (browser)
3. **E2E Testing** (`/e2e`) — Playwright test suite (baru dibuat)

**Stack:**
- Flutter 3.41.8 + Riverpod 2.5.1 + Drift 2.16 (SQLite **hanya face_embeddings**) + Supabase 2.3.4
- flutter_animate 4.5.0 untuk animasi deklaratif
- go_router 14 untuk routing, TFLite 0.11 untuk face recognition
- Next.js + framer-motion 12 (admin web), Playwright 1.59.1 (e2e test)

**Arsitektur Data (per 2026-05-19):**
- SQLite/Drift: **hanya tabel `face_embeddings`** — data biometrik disimpan lokal untuk akses offline saat absen
- Semua data lain (attendance, users, students, grades, leave_requests, notifications, settings) → **Supabase langsung**
- Face embedding di-sync ke Supabase saat online (flag `syncedToSupabase`)

**Master spec:** `CLAUDE_UPDATED.md` (di root `/ambis`)

---

## Design System (Light Theme)

Semua screen siswa & orang tua menggunakan **light theme** dari Stitch project `1521715147011872403`:

| Token | Hex | Penggunaan |
|---|---|---|
| `background` | `#F7F9FB` | Scaffold background |
| `surface` | `#FFFFFF` | Card, panel |
| `primary` | `#001736` | Header, nav text |
| `primary-container` | `#002B5B` | AppBar bg logo area |
| `secondary` | `#006A63` | Teal — CTA, status Hadir, active |
| `secondary-container` | `#47FBEB` | Cyan accent |
| `on-surface` | `#191C1E` | Body text |
| `on-surface-variant` | `#43474F` | Secondary text |
| `outline` | `#747780` | Hint text, borders |
| `outline-variant` | `#C4C6D0` | Divider, card border |
| `tertiary-fixed` | `#FFDF9E` | Gold (late badge bg) |
| `error` | `#BA1A1A` | Error, Alfa status |

**Font:** Lexend (belum diimplementasi di Flutter, masih default)

**Pola card:** `Container(clipBehavior: Clip.hardEdge)` + strip 4px kiri (border teal/cyan/navy) = identitas visual semua card

---

## Status Halaman — Flutter Mobile

### ✅ Selesai & Light Theme

| Screen | File | Route | Catatan |
|---|---|---|---|
| Splash | `auth/screens/splash_screen.dart` | `/splash` | Dark gradient (sengaja, loading) |
| Welcome | `auth/screens/welcome_screen.dart` | `/welcome` | Dark gradient (intro branding) |
| Login Siswa | `auth/screens/login_screen.dart` | `/login` | Light theme |
| Login Orang Tua | `auth/screens/parent_login_screen.dart` | `/parent-login` | Light theme |
| Verifikasi NISN | `enrollment/screens/nisn_verification_screen.dart` | `/nisn-verify` | Light theme |
| Registrasi Wajah | `enrollment/screens/enrollment_screen.dart` | `/enrollment`, `/enroll-face/:userId` | Camera + TFLite |
| Beranda Siswa | `dashboard/screens/dashboard_screen.dart` | `/dashboard` | Light, riwayat inline, 0 warnings |
| Presensi Wajah | `attendance/screens/attendance_screen.dart` | `/attendance` | Push, kamera penuh |
| Laporan Nilai | `grades/screens/grades_screen.dart` | `/grades` | Light, tab Sem 1/2, dummy data |
| Riwayat Kehadiran | `history/screens/history_screen.dart` | `/history` | Light, kalender interaktif |
| Pengajuan Izin | `leave_request/screens/leave_request_screen.dart` | `/leave` | Light, image picker |
| Notifikasi | `notifications/screens/notifications_screen.dart` | `/notifications` | Light, dummy data |
| Profil Siswa | `profile/screens/profile_screen.dart` | `/profile` | Light, logout dialog |
| Dashboard Orang Tua | `parent/screens/parent_dashboard_screen.dart` | `/parent-dashboard` | Light, tanpa bottom nav |
| Riwayat Absensi (Ortu) | `parent/screens/parent_attendance_history_screen.dart` | `/parent-history` | Light, filter bulan |

### Bottom Navigation (App Shell)

File: `shared/widgets/app_shell.dart`
4 tab: **Beranda** | **Absensi** (push, bukan shell) | **Nilai** | **Profil**

---

## Status Halaman — Admin Web (Next.js)

Semua ada di `/web/app/`:

| Halaman | Route | Status |
|---|---|---|
| Dashboard Utama Admin | `/` | ✅ Live — stat cards + absence table + GeofenceSection |
| Persetujuan Izin & Sakit | `/attendance` | ✅ Live — approve/reject dengan dialog alasan penolakan |
| Input Nilai Siswa | `/grades` | ✅ Live — input UTS/UAS per kelas/mapel/semester, pagination |
| Manajemen Data Siswa | `/students` | ✅ Live — CRUD lengkap (Add, Edit, Reset Face) |

### Komponen Baru

| Komponen | File | Keterangan |
|---|---|---|
| `StudentModal` | `components/students/StudentModal.tsx` | Modal add/edit siswa |
| `ResetFaceDialog` | `components/students/ResetFaceDialog.tsx` | Dialog konfirmasi reset face embedding |
| `MapPicker` | `components/dashboard/MapPicker.tsx` | Leaflet map (client-only, no SSR) |
| `GeofenceSection` | `components/dashboard/GeofenceSection.tsx` | Toggle + peta + form koordinat + simpan |

### API Routes

| Route | File | Keterangan |
|---|---|---|
| `POST /api/students` | `app/api/students/route.ts` | Create siswa — server-side, pakai `SUPABASE_SERVICE_ROLE_KEY` |

### Supabase — tabel `settings`

4 key geofencing sudah di-seed:

| key | type | default |
|---|---|---|
| `geofence_enabled` | bool | `true` |
| `geofence_radius` | int | `50` |
| `school_lat` | double | `''` (diisi dari web) |
| `school_lng` | double | `''` (diisi dari web) |

RLS: anon read + write (web admin belum ada auth — Phase 4).

---

## Routing Logic (`app_router.dart`)

```
/splash → loading screen (sebelum auth resolve)

Jika belum login → /welcome
  /welcome → /login atau /parent-login atau /nisn-verify

Jika login sebagai ortu → /parent-dashboard
  Dari /parent-dashboard → push /parent-history

Jika login sebagai siswa → /dashboard (shell)
  Shell: /dashboard, /grades, /profile
  Push: /attendance, /leave, /notifications, /history
```

**Penting:** Router TIDAK melakukan redirect global berdasarkan status enrollment wajah.
Cek enrollment hanya terjadi di dalam `/attendance` screen:
- Jika wajah belum terdaftar → tampil `_NotEnrolledView` inline → tombol push ke `/enrollment`
- Halaman lain (dashboard, nilai, profil, dll.) bebas diakses tanpa cek enrollment

---

## Data & State

### Dummy Data (belum connect ke Supabase)
- ~~`grades/data/repositories/grade_repository.dart` — seed 10 mapel SMA, 2 semester~~ ✅ Selesai (2026-05-07)
- ~~`notifications/data/dummy_notifications.dart` — 3 dummy notif~~ ✅ Selesai (2026-05-07)
- ~~`parent/screens/parent_dashboard_screen.dart` — attendance % hardcoded~~ ✅ Selesai (2026-05-07)
- ~~`parent/screens/parent_attendance_history_screen.dart` — dummy records per bulan~~ ✅ Selesai (2026-05-07)

### Real Data (dari Supabase)
- Auth: `auth/providers/auth_provider.dart` → Supabase Auth
- Absensi hari ini: `dashboard_screen.dart` → query `attendance` table (SQLite)
- Riwayat absensi: `history/providers/history_provider.dart` → query per bulan (SQLite)
- Profil: `profile_screen.dart` → query `students` table (SQLite)
- Face embedding: `enrollment/repositories/face_repository.dart` → `face_embeddings` table
- **Nilai siswa:** `grades/providers/grades_provider.dart` → Supabase `grades` table (langsung)
- **Notifikasi:** `notifications/providers/notifications_provider.dart` → Supabase `notifications` table
- **Parent — info anak:** `parent/providers/parent_provider.dart` → Supabase `students` + `users`
- **Parent — nilai anak:** `parent/providers/parent_provider.dart` → Supabase `grades` table

### Database Tables (Drift / SQLite)
`face_embeddings` ← **hanya ini yang tersisa di SQLite**

Semua tabel lain (`attendance`, `attendance_queue`, `audit_log`, `grades`, `leave_requests`, `settings`, `students`, `users`) telah dihapus dari Drift — data diambil langsung dari Supabase.

---

## E2E Testing (Playwright)

Folder: `/e2e/`
- `playwright.config.js` — baseURL `http://localhost:5000`, headless Chromium
- `tests/example.spec.js` — contoh test pertama

**Cara pakai:**
```bash
# Terminal 1: jalankan Flutter web
cd ambis_attendance && flutter run -d chrome --web-port 5000

# Terminal 2: jalankan test
cd e2e && npm test          # headless
npm run test:headed         # lihat browser
npm run test:ui             # Playwright UI
```

---

## Yang Belum Dikerjakan (Next Steps)

### Priority Tinggi
1. ~~**Hubungkan parent dashboard ke data real**~~ — ✅ Selesai (2026-05-07)
2. ~~**Face sync ke Supabase**~~ — ✅ Selesai (2026-05-07)
3. ~~**Hubungkan halaman Attendance & Grades web ke Supabase**~~ — ✅ Selesai (2026-05-08)

### Priority Menengah
4. ~~**Liveness detection** — Euler angles (head tilt check) di attendance flow~~ ✅ Selesai (2026-05-08)
5. ~~**Leave request status tracking** — tampilkan alasan penolakan, izinkan re-upload~~ ✅ Selesai (2026-05-08)
6. ~~**fl_chart** — chart nilai di `grades_screen.dart`~~ ✅ Selesai (2026-05-08)

### Priority Rendah (Phase 4)
7. ~~**Admin auth** — login page untuk web dashboard (saat ini anon RLS terbuka)~~ ✅ Selesai (2026-05-08)
8. ~~**Demo mode** — akun demo + sample data~~ ✅ Selesai (2026-05-08)
9. ~~**Audit log** — catat semua aksi admin~~ ✅ Selesai (2026-05-08)

---

## File Penting

| Path | Isi |
|---|---|
| `CLAUDE_UPDATED.md` | Master spec — acuan semua keputusan |
| `DATABASE_SCHEMA.md` | Skema lengkap semua tabel |
| `NOTIFICATIONS_GUIDE.md` | Panduan FCM setup |
| `core/router/app_router.dart` | Seluruh routing + redirect logic |
| `core/database/app_database.dart` | Drift DB setup |
| `core/constants/colors.dart` | AppColors (dark — warisan lama, sebagian masih dipakai) |

---

## Perubahan Terakhir (2026-05-06)

### Sesi 1 — Router & Enrollment
- **Router cleanup:** Dihapus komentar misleading `// Logged in. Now check enrollment for siswa role only.` di `app_router.dart`.
- **Perilaku enrollment diperjelas:** Redirect ke `/enrollment` HANYA terjadi di `attendance_screen.dart`. Tidak ada global redirect.

### Sesi 2 — Color System Overhaul
- **`AppColors` ditulis ulang** (`core/constants/colors.dart`) menggunakan Material 3 light theme tokens dari DESIGN.md (SMAN 07 Academic Design System). Primary navy `#001736`, secondary teal `#006A63`, tertiary gold, background `#F7F9FB`.
- **Dark screen tokens** ditambahkan sebagai namespace `AppColors.dark*` — dipakai oleh splash, welcome, scanner, gradient_background (sengaja dark, jangan diubah).
- **`app_theme.dart`** diubah ke `ThemeData.light` dengan `ColorScheme` baru.
- **`text_styles.dart`** diperbarui ke `onSurface` / `onSurfaceVariant`.

### Sesi 3 — Web CRUD + Geofencing
- **Students CRUD fungsional:** Tambah siswa (via API route server-side + service role key), edit nama/kelas/status, reset face embedding — semua terhubung Supabase.
- **RLS diperluas:** Anon policies ditambahkan ke `users` (SELECT + UPDATE), `students` (SELECT + UPDATE), `face_embeddings` (SELECT + DELETE) agar web admin bisa beroperasi tanpa auth.
- **Geofence admin section:** Section baru di Dashboard (`/`) — toggle ON/OFF, peta Leaflet interaktif (klik untuk set koordinat), input manual lat/lng/radius, simpan ke tabel `settings`.
- **Flutter geofencing dinamis:** `attendance_screen.dart` kini membaca `school_lat`, `school_lng`, `geofence_radius`, `geofence_enabled` dari Supabase via `geofenceSettingsProvider` (FutureProvider). Fallback ke `AppConstants` jika query gagal.
- **Bug fix:** Bracket mismatch di `attendance_screen.dart` (pre-existing, `Column.children` tidak tertutup) diperbaiki.

---

### Sesi 4 — Face Embedding Fix + Offline Sync (2026-05-07)

- **Fix TFLite shape mismatch:** `AppConstants.embeddingSize` diubah `128 → 192` (`core/constants/app_constants.dart`). Root cause: model `mobilefacenet.tflite` output shape `[1, 192]` tapi buffer dialokasikan `[1, 128]` → crash "Output object shape mismatch".
- **Lingkaran enrollment lebih besar:** Outer container `256 → 300px`, camera preview `240 → 284px`, scan animation reference diupdate ikut (`enrollment_screen.dart`).
- **Offline-first face sync:**
  - Kolom `syncedToSupabase BOOLEAN DEFAULT false` ditambahkan ke tabel `face_embeddings` (`tables/face_embeddings.dart`).
  - `AppDatabase` naik ke `schemaVersion 2` dengan `onUpgrade` yang memanggil `addColumn` untuk migrasi perangkat lama (`app_database.dart`).
  - `saveEmbedding` di `face_repository_native.dart` menulis `syncedToSupabase: false` saat simpan lokal.
  - `SyncRepository.syncPendingFaceEmbeddings()` ditambahkan — query baris belum tersync, upsert ke tabel Supabase `face_embeddings` sebagai `float4[]`, tandai `syncedToSupabase = true` (`sync_repository.dart`).
  - `SyncCoordinator.triggerNow()` kini memanggil keduanya: `syncPendingAttendance()` + `syncPendingFaceEmbeddings()` (`sync_provider.dart`).
  - Kode di-codegen ulang (`build_runner build`) — 0 error, 0 warning baru.

**Tabel Supabase yang perlu dibuat (belum ada):**
```sql
create table face_embeddings (
  id text primary key,
  student_id text unique not null,
  embedding float4[] not null,
  enrollment_date bigint not null,
  updated_at bigint not null,
  is_active boolean not null default true
);
```

---

### Sesi 5 — Supabase Data Migration (2026-05-07)

**Semua dummy/hardcoded data diganti dengan data real dari Supabase.**

#### Grades
- **Dihapus:** 60 baris seed data dummy + method `seedIfEmpty` + `getGradesByStudent` dari `grade_repository.dart`.
- **Ditambahkan:** `getGradesFromSupabase(studentId, semester)` — query langsung ke tabel `grades` Supabase. Tidak ada lagi caching ke SQLite lokal untuk nilai.
- **`grades_provider.dart`** diupdate: tidak lagi panggil `seedIfEmpty`, langsung return dari Supabase. Jika belum ada data → empty state ("Nilai belum tersedia.").
- **Test file** (`grade_repository_test.dart`) diperbarui: test SQLite in-memory lama dihapus, diganti smoke test untuk model `SubjectGrade` dan `GradeSummary`.

#### Notifications
- **Dihapus:** `dummy_notifications.dart` + `kDummyNotifications` list.
- **Ditambahkan (baru):**
  - `notifications/data/models/notification_model.dart` — model `AppNotification` (parse dari Supabase `notifications` table).
  - `notifications/data/repositories/notification_repository.dart` — `getNotifications(userId)`, `markAsRead(id)`, `markAllAsRead(userId)`.
  - `notifications/presentation/providers/notifications_provider.dart` — `AutoDisposeAsyncNotifier`, update optimistis saat mark as read.
- **`notifications_screen.dart`** dikonversi dari `StatefulWidget` ke `ConsumerWidget`. Tap notif → update Supabase + optimistic UI. "Tandai Semua" → batch update Supabase.

#### Parent Dashboard
- **Dihapus:** `'XI IPA 1'` hardcoded, `'98%'` hardcoded, 3 baris nilai hardcoded, rata-rata kelas `'87.5'` hardcoded.
- **Ditambahkan (baru):**
  - `parent/data/repositories/parent_repository.dart` — `getChildInfo(parentId)` (join `students` + `users`), `getChildGradesSummary(studentId)`, `getChildOverallAverage(studentId)`.
  - `parent/presentation/providers/parent_provider.dart` — 3 FutureProvider: `childInfoProvider`, `childGradesSummaryProvider`, `childOverallAverageProvider`.
- **`parent_dashboard_screen.dart`** ditulis ulang: nama, kelas, NISN siswa real dari Supabase. Nilai UTS real dari Supabase. Rata-rata real dari Supabase. Attendance card menampilkan `-` (data absensi dikosongkan per keputusan).
- Jika `parent_id` belum terhubung ke siswa manapun → tampil `_NoChildState` ("Hubungi admin sekolah").

#### Parent Attendance History
- **Dihapus:** `_records` (5 dummy records), `_months` (hardcoded 4 bulan 2023), `_stats` (hardcoded hadir/izin/sakit/alpa), nama "Ahmad Fauzi", kelas "XII MIPA 1", NISN "19201004".
- **Ditambahkan:** Student info (nama, kelas, NISN, initials) real dari `childInfoProvider`. Filter bulan digenerate dinamis (6 bulan terakhir dari tanggal sekarang). Stats absensi ditampilkan 0. Record list menampilkan `_EmptyAttendanceCard`.

#### Status analyze
- `flutter analyze --no-fatal-infos` → **0 error, 0 warning** (18 info `prefer_const`, pre-existing).
- Satu error pre-existing di `face_repository_native.dart` (`syncedToSupabase` parameter) — tidak disentuh di sesi ini.

---

### Sesi 6 — Web Admin Supabase Integration (2026-05-08)

**Halaman `/attendance` dan `/grades` di web admin sekarang terhubung penuh ke Supabase.**

#### RLS Policies (Migration applied)
- **`leave_requests`**: ditambahkan `anon_select_leave_requests` (SELECT) + `anon_update_leave_requests` (UPDATE). Sebelumnya tidak ada policy sama sekali → semua query gagal tanpa error yang jelas.
- **`grades`**: ditambahkan `anon_select_grades` (SELECT) + `anon_insert_grades` (INSERT) + `anon_update_grades` (UPDATE). Sebelumnya hanya ada `siswa_own_grades` (authenticated only) → web admin tidak bisa baca/tulis nilai.

#### `/attendance` (`web/app/attendance/page.tsx`)
- **Fix join query:** `students(fullname, class)` → `students!student_id(class, users!id(fullname))`. Root cause: `fullname` ada di tabel `users`, bukan `students`. Join nested dua tingkat diperlukan.
- **Dialog alasan penolakan:** Tombol "Tolak" sekarang membuka modal dengan textarea (opsional). Alasan tersimpan ke kolom `rejected_reason` di Supabase + `reviewed_at` timestamp.
- **Loading state per-tombol:** Tombol Setujui/Tolak disable saat sedang memproses, mencegah double-click.
- **Label diindonesiakan:** "Approve" → "Setujui", "Reject" → "Tolak", header diubah ke Bahasa Indonesia.

#### `/grades` (`web/app/grades/page.tsx`)
- **Fix query:** Diubah dari `users` join ke `students` join (`students!id(fullname)`) — lebih sesuai skema karena `students.id = users.id`.
- **Tombol Simpan hanya aktif saat ada editan** (`hasEdits` flag) — mencegah upsert kosong.
- **Tombol Refresh** untuk reload manual tanpa mengubah filter.
- **Notifikasi sukses** muncul 3 detik setelah save berhasil.
- **Validasi input** 0–100 di sisi klien sebelum kirim ke Supabase.
- **Status badge diperbarui:** "Pending" → "Kosong", "Editing..." → "Belum disimpan", "✓ Saved" → "✓ Tersimpan".

#### Status Web Admin sekarang
Semua halaman web admin sudah live dan terhubung Supabase:
- `/` — Dashboard + Geofence + Ringkasan Nilai ✅
- `/students` — CRUD lengkap + kolom Orang Tua ✅
- `/attendance` — Approve/Reject izin & sakit ✅
- `/grades` — Input nilai **mode per-siswa** (10 mapel berjejer, prev/next siswa) ✅
- `/notifications` — Broadcast dengan filter preferensi ✅
- `/audit` — Log semua aksi admin ✅
- `/demo` — Seed & hapus data demo ✅

---

### Sesi 7 — Priority Menengah Flutter (2026-05-08)

**Tiga fitur Priority Menengah selesai semua.**

#### Liveness Detection — Euler Angles (`scanner_screen.dart`)
- **Ditambahkan state `waitingHeadTurn`** di antara `waitingBlink` dan `passed`.
- Flow liveness baru: **Kedip → Toleh kepala → Pencocokan wajah**.
- `_checkHeadTurn()`: deteksi `headEulerAngleY.abs() > 25` (kepala memandang >25° ke kiri/kanan) menggunakan Google ML Kit.
- Timeout 6 detik jika tidak ada gerakan. Gagal → reset ke `waitingBlink`.
- Kombinasi blink + head-turn membuat liveness tidak bisa ditipu dengan foto statis.

#### Leave Request Re-Upload (`leave_request_screen.dart`)
- **Tombol "Ajukan Ulang"** muncul di `_LeaveCard` hanya untuk status `rejected`.
- Tap → memanggil `_prefillFrom()` yang mengisi ulang form (tipe izin, tanggal, alasan) dari data pengajuan yang ditolak.
- Scroll otomatis ke atas form menggunakan `_scrollCtrl.animateTo(0)`.
- User hanya perlu upload bukti baru dan submit — semua field lain sudah terisi.

#### fl_chart Grades (`grades_screen.dart`)
- **Widget `_GradesChart`** ditambahkan di antara semester toggle dan tabel nilai.
- Grouped bar chart: dua batang per mata pelajaran (UTS = teal `#006A63`, UAS = biru `#405F91`).
- Label X otomatis disingkat (huruf pertama setiap kata, max 5 karakter jika satu kata).
- Touch tooltip menampilkan nilai UTS/UAS saat batang disentuh.
- Legend "UTS / UAS" di pojok kiri atas chart.
- Grid horizontal setiap 25 poin, tanpa border, Y max otomatis dari nilai tertinggi + 10.

#### Status analyze
- `dart analyze` (3 file yang diubah) → **0 issues found**

---

### Sesi 8 — Phase 4 + Attendance Fix (2026-05-08)

#### Flutter: Attendance Screen Auto-Detection (`attendance_screen.dart`)
- **Dihapus `_KindSelector`** (tab manual Absen Masuk / Absen Pulang).
- Saat layar dibuka, `_loadTodayRecord()` query SQLite via `getTodayAttendance()`:
  - Null → `_kind = checkIn`, judul "Absen Masuk"
  - `timeIn` ada, `timeOut` null → `_kind = checkOut`, tampil "Masuk tercatat: HH:MM"
  - Keduanya ada → tampil `_AllDoneView` ("Presensi Hari Ini Selesai" + jam masuk/pulang)
- `dart analyze` → 0 issues.

#### Web: Admin Auth (`middleware.ts`, `lib/supabase-server.ts`, `app/login/page.tsx`)
- **`middleware.ts`**: Proteksi semua route, redirect ke `/login` jika belum auth, redirect ke `/` jika sudah auth.
- **`lib/supabase-server.ts`**: Server-side Supabase client factory menggunakan `@supabase/ssr` `createServerClient`.
- **`app/login/page.tsx`**: Form email + password, cek role 'admin' setelah login. Jika bukan admin → sign out + tampil error.
- **`Sidebar.tsx`**: Logout button diwire ke `supabase.auth.signOut()` + `router.push('/login')`.

#### Web: Audit Log (`audit_log` table, `app/audit/page.tsx`)
- **Migration Supabase**: Tabel `audit_log` dibuat (id, action, entity_type, entity_id, old_value, new_value, created_at bigint). RLS anon insert + select.
- **`app/attendance/page.tsx`**: `handleApprove` dan `handleReject` sekarang insert ke `audit_log` setelah action sukses (non-blocking try/catch).
- **`app/grades/page.tsx`**: `saveAll` insert batch audit rows untuk setiap nilai yang di-upsert.
- **`app/audit/page.tsx`**: Halaman read-only — 100 log terbaru, badge warna per aksi, timestamp `id-ID` locale, empty state.
- **Sidebar**: Link "Audit Log" ditambahkan.

#### Web: Demo Mode (`app/demo/page.tsx`)
- **`app/demo/page.tsx`**: Dua tombol — Seed Data + Hapus Data Demo.
- Seed: 5 siswa demo (ID tetap `demo0000-...`), nilai UTS+UAS 3 mapel, absensi 5 hari kerja terakhir, 2 leave request pending.
- Delete: Hapus semua baris terkait ID tetap dalam urutan FK yang benar.
- **Sidebar**: Link "Demo Data" ditambahkan.

#### Status TypeScript
- `npx tsc --noEmit` → **0 errors**

---

### Sesi 9 — Bug Fixes Android Build & Flutter Runtime (2026-05-19)

#### Android Build — Java Home Fix
- **`android/gradle.properties`**: `org.gradle.java.home` diubah dari `jdk-17` (tidak ada) → `jdk-23.0.2` (terinstall di sistem).

#### Android Build — Obsolete Java 8 Warning
- **`android/build.gradle.kts`**: Ditambahkan blok `subprojects { afterEvaluate { tasks.withType<JavaCompile>() } }` yang memaksa semua plugin pihak ketiga (google_mlkit, dll.) menggunakan Java 17 dan menekan warning `-Xlint:-options`. Warning muncul karena plugin-plugin tersebut punya `build.gradle` sendiri di Pub Cache yang hardcode Java 8.

#### Flutter Runtime — BorderRadius + Non-Uniform Border
- **Root cause:** `BoxDecoration` dengan `borderRadius` tidak boleh pakai `Border` dengan warna berbeda di tiap sisi. Pola strip kiri (teal 4px) yang lama menggunakan `Border(left: teal, top/right/bottom: gray)` → crash.
- **Fix pattern:** Ganti ke `Container(clipBehavior: Clip.hardEdge)` + `Border.all(color: gray)` + strip kiri sebagai `Container(width: 4)` di dalam `Row`.
- **`grades_screen.dart` (`_GradesTableCard`)**: Direstrukturisasi ke pola baru.
- **`profile_screen.dart` (`_AkademikCard`)**: Direstrukturisasi ke pola baru.
- **`login_screen.dart` (Face Registration Banner)**: Wrap `Container` dengan `ClipRRect`, hapus `borderRadius` dari `BoxDecoration`.

#### Flutter Runtime — Failed Assertion rendering/object.dart:5493
- **Root cause:** `Row(crossAxisAlignment: CrossAxisAlignment.stretch)` membutuhkan height yang *bounded*, tapi kedua card berada di dalam `Column` yang memberi unbounded height ke children-nya.
- **Fix:** Tambah `IntrinsicHeight` sebagai wrapper `Row` di `_GradesTableCard` dan `_AkademikCard`.
- `dart analyze` → **0 issues** di semua file yang diubah.

#### Supabase — face_embeddings vector dimension mismatch
- **Root cause:** Kolom `face_embeddings.embedding` masih `vector(128)` di Supabase, sedangkan app sudah menggunakan MobileFaceNet output 192 dimensi sejak Sesi 4.
- **Fix:** Migration `fix_embedding_vector_192` diapply langsung ke Supabase production:
  ```sql
  ALTER TABLE face_embeddings
    ALTER COLUMN embedding TYPE vector(192)
    USING embedding::text::vector(192);
  ```
- Kolom sekarang `vector(192)` — enrollment wajah + sync ke Supabase kembali berfungsi.

---

### Sesi 10 — SQLite Simplification + UI Polish + Akun Ortu + Notif Prefs (2026-05-19)

Sesi besar: 3 sub-agen paralel mengerjakan Flutter, Web Admin, dan Supabase migrations sekaligus.

#### SQLite Simplification (Flutter)

- **Dihapus 8 tabel Drift:** `users`, `students`, `attendance`, `attendance_queue`, `grades`, `leave_requests`, `audit_log`, `settings`. Hanya `face_embeddings` yang tersisa.
- **`app_database.dart`** — `schemaVersion` bump ke `4`, hanya register `FaceEmbeddings`, hapus `_seedDefaultSettings()`.
- **`attendance_repository.dart`** — Ditulis ulang: hapus semua Drift logic, tulis attendance langsung ke Supabase (`from('attendance').upsert(...)`). `getTodayAttendance()` kini query Supabase. Settings (time window, threshold) dibaca dari tabel `settings` Supabase.
- **`attendance_history_repository.dart`** — Ditulis ulang pakai Supabase untuk query `attendance` dan `leave_requests`.
- **`sync_repository.dart`** — Dihapus `syncPendingAttendance()` dan `countByStatus()`. Hanya `syncPendingFaceEmbeddings()` yang tersisa.
- **`sync_provider.dart`** — Dihapus `pendingSyncCountProvider`, disesuaikan tanpa attendance sync.
- **`dashboard_screen.dart`** — Provider `_todayAttendanceProvider` dan `_recentAttendanceProvider` kini query Supabase langsung (return `Map<String,dynamic>?`). Hapus import `app_database.dart` dari file ini.
- **`attendance_screen.dart`** — Update state dari `AttendanceEntity?` ke `Map<String,dynamic>?`.
- **`leave_repository.dart`**, **`leave_provider.dart`**, **`leave_request_screen.dart`** — Ditulis ulang ke Supabase langsung.
- **`profile_screen.dart`** — Query student/user data dari Supabase (hapus SQLite dependency).
- **`auth_repository.dart`** — Hapus semua SQLite write, pure Supabase.
- **`UserEntity`** — Dibuat sebagai plain Dart class baru (`lib/features/auth/data/models/user_entity.dart`), menggantikan Drift-generated entity yang sudah tidak ada.

#### Popup Sukses Absen (Flutter)

- **`attendance_screen.dart`** — Method `_commit()` kini memanggil `_showSuccessDialog()` sebelum navigate ke dashboard.
- Dialog **check-in**: judul "Selamat Belajar!", ikon `Icons.school`, warna teal `#006A63`, tombol "OK, Mulai Belajar".
- Dialog **check-out**: judul "Hati-hati di Jalan!", ikon `Icons.directions_walk`, warna gold `#F5B800`, tombol "Sampai Jumpa".
- Animasi: `TweenAnimationBuilder` scale `0.7 → 1.0` (Curves.easeOutBack, 400ms) + fade-in.

#### Animasi flutter_animate (Flutter)

- **Dependency tambah:** `flutter_animate: ^4.5.0` di `pubspec.yaml`.
- **`dashboard_screen.dart`** — 4 widget utama (Greeting, StatusCard, QuickActions, Riwayat) stagger `.animate().fadeIn().slideY(begin: 0.08)` delay 50–200ms.
- **`parent_dashboard_screen.dart`** — 3 card (Profile, Attendance, Grades) stagger delay 80–240ms.
- **`notifications_screen.dart`** — List item `_NotificationItem` stagger fadeIn per index.
- **`grades_screen.dart`** — Chart `_GradesChart` + tabel `_GradesTableCard` fadeIn + slideX.

#### Pengaturan Notifikasi Inline (Flutter)

- **File baru `notification_preferences_model.dart`** — class `NotificationPreferences` (5 toggle: attendance, grade, leave, announcement, system).
- **File baru `notification_preferences_repository.dart`** — `getPreferences(userId)`, `upsert(prefs)` ke Supabase.
- **File baru `notification_preferences_provider.dart`** — `AutoDisposeAsyncNotifier` untuk read/write preferences.
- **`notifications_screen.dart`** — Tambah `IconButton(Icons.tune_rounded)` di AppBar → `showModalBottomSheet` dengan 5 `SwitchListTile` per kategori + tombol Simpan.

#### Web Admin — Akun Orang Tua

- **`components/students/StudentModal.tsx`** — Section opsional "Tambahkan Akun Orang Tua" (checkbox + 4 field: nama, email, telepon, password). Hanya muncul di mode Add.
- **`app/api/students/route.ts`** — Jika `body.parent` ada: create auth user ortu, insert `users` (role='ortu'), update `students.parent_id`. Rollback penuh jika salah satu step gagal. Log ke `audit_log` dengan action `'create_parent'`.
- **`app/students/page.tsx`** — Kolom "Orang Tua" di tabel: nama ortu (teal) atau badge "Belum ditautkan". Query join `parent:parent_id(fullname, phone)`.

#### Web Admin — Ringkasan Nilai di Dashboard

- **`app/page.tsx`** — Section "Ringkasan Nilai" (2 card side-by-side):
  - Card kiri: rata-rata nilai per kelas (group-by, top 5, warna hijau/merah berdasarkan ≥75).
  - Card kanan: 5 input nilai terbaru (nama siswa, mapel, UTS/UAS, score, tanggal).

#### Web Admin — Grade Input Mode Per-Siswa

- **`app/grades/page.tsx`** — Rewrite besar:
  - Hapus state `selectedSubject` dan filter datalist mapel.
  - Filter ketiga kini dropdown **Siswa** (dari kelas yang dipilih).
  - Tabel: 10 baris MATA PELAJARAN tetap untuk 1 siswa (bukan list siswa untuk 1 mapel).
  - State `entries` keyed by subject: `{ uts, uas, status, utsId?, uasId? }`.
  - Navigasi "← Sebelumnya / Berikutnya →" untuk ganti siswa tanpa reload halaman.
  - Hapus pagination (10 mapel selalu muat tanpa scroll).
  - Tabel fade animasi (framer-motion `key={selectedStudent}`) saat ganti siswa.

#### Web Admin — framer-motion + Filter Notif

- **`package.json`** — `framer-motion: ^12` diinstall.
- **`components/dashboard/StatCard.tsx`** — client component baru, `motion.div` stagger delay per index.
- **`components/students/StudentModal.tsx`** — `AnimatePresence` + backdrop fade + content scale.
- **`app/grades/page.tsx`** — tabel `motion.div` fade saat ganti siswa.
- **`app/api/notifications/route.ts`** — Cek `notification_preferences` sebelum batch insert, skip user yang disable kategori tersebut.

#### Supabase Migrations Applied

- `20260519_parent_role_rls`: Index `idx_students_parent_id`, policy `ortu_own_profile_select`, policy `ortu_child_select`.
- `20260519_notification_preferences`: Tabel `notification_preferences` (user_id PK, 5 bool kolom, RLS enable, 3 policy).

#### Status

- `flutter analyze --no-fatal-infos` → **0 issues**
- `npx tsc --noEmit` → **0 errors**
- Commit push: `github.com/Keroo0/ambis-attendance` dan `github.com/Keroo0/ambis-admin`

---

## Catatan Penting

- **SQLite sekarang hanya untuk `face_embeddings`**. Jangan tambahkan tabel Drift baru kecuali ada kebutuhan offline yang sangat kuat. Semua data lain Supabase langsung.
- **`AppDatabase` schemaVersion = 4**. Migration terakhir di `onUpgrade`: tambah kolom `syncedToSupabase` (from < 2).
- **`AppColors`** di `colors.dart` sudah diperbarui ke **light theme** (Material 3). Semua screen Flutter sudah menggunakan token baru. Token `AppColors.dark*` dipakai khusus oleh screen yang sengaja dark.
- **`splash_screen.dart`**, **`welcome_screen.dart`**, **`scanner_screen.dart`**, **`gradient_background.dart`** sengaja tetap dark — pakai `AppColors.dark*`. Jangan ganti ke light.
- **`leave_request_screen.dart`** menggunakan `dart:io` (File) — potensi issue di web build. Perlu conditional import seperti enrollment.
- **Web `settings.updated_at`** adalah `BIGINT` (Unix epoch), bukan TIMESTAMPTZ. Setiap upsert ke tabel `settings` harus menyertakan `updated_at: Math.floor(Date.now() / 1000)`.
- **Web admin auth sudah ada** — `middleware.ts` proteksi semua route, login via `/login` dengan cek `role = 'admin'`.
- **`SUPABASE_SERVICE_ROLE_KEY`** harus ada di `ambis-admin/.env.local` — dipakai oleh `POST /api/students` untuk membuat Supabase Auth user. Jangan commit ke git.
- **Akun orang tua** dibuat dari admin web `/students` → "Tambah Siswa" → centang "Tambahkan Akun Orang Tua". Link `students.parent_id` diisi otomatis saat submit.
- **`UserEntity`** sekarang plain Dart class di `lib/features/auth/data/models/user_entity.dart` (bukan Drift-generated). Fieldnya: `id, nisn, passwordHash, role, fullname, email, phone, avatarUrl, isActive`.
- **flutter_animate** dipakai di: `dashboard_screen`, `parent_dashboard_screen`, `notifications_screen`, `grades_screen`. Import: `import 'package:flutter_animate/flutter_animate.dart';`
- **Login ortu:** pakai NISN anak + password. Synthetic email = `{nisn_anak}@ortu.sman07.local` untuk Supabase Auth. Method `AuthRepository.loginParent(nisnAnak, password)` dipakai oleh `ParentLoginScreen`.

---

### Sesi 11 — Fix Login Ortu + Dashboard Ortu Expanded (2026-05-19)

#### Bug Fix: Parent Login Broken

- **Root cause:** `parent_login_screen.dart` memanggil `authProvider.notifier.login()` yang menghasilkan email `{nisn}@sman07.local` (domain siswa), tapi akun ortu dibuat dengan email berbeda di Supabase Auth.
- **Fix pilihan:** Login ortu via **NISN ANAK + Password** menggunakan email sintesis `{nisn_anak}@ortu.sman07.local`.
- **`app_constants.dart`** — Tambah `authParentEmailDomain = 'ortu.sman07.local'`.
- **`auth_repository.dart`** — Tambah `nisnToParentEmail(nisnAnak)` dan `loginParent({nisnAnak, password})`. Method ini memverifikasi `role == 'ortu'` setelah login — jika bukan, sign out dan throw error.
- **`auth_provider.dart`** — Tambah `loginParent(nisnAnak, password)` ke `AuthNotifier`.
- **`parent_login_screen.dart`** — Ganti `login()` → `loginParent()`.
- **`app/api/students/route.ts`** — Ganti email Supabase Auth ortu dari `body.parent.email` → `${nisn.trim()}@ortu.sman07.local`. Hapus duplikasi cek email nyata.
- **`components/students/StudentModal.tsx`** — Hapus field "Email Orang Tua" dari form (tidak diperlukan lagi). Validasi email dihapus.

#### Parent Dashboard Expansion

- **`parent_repository.dart`** — Update `ChildGradeRow`: `utsScore` dan `uasScore` sekarang optional (`double?`). `getChildGradesSummary()` ditulis ulang untuk pivot UTS+UAS per mapel dalam satu query. Tambah:
  - `ChildTodayAttendance` class (timeIn, timeOut, isPresent)
  - `getChildTodayAttendance(studentId)` — query `attendance` table hari ini
  - `ChildLeaveRequest` class (id, type, dateFrom, dateTo, status, reason)
  - `getChildLeaveRequests(studentId)` — 5 pengajuan izin terbaru
- **`parent_provider.dart`** — Tambah `childTodayAttendanceProvider` dan `childLeaveRequestsProvider`.
- **`parent_dashboard_screen.dart`** — Ditulis ulang dengan 4 section:
  1. Row: ProfileCard + AttendanceCard (bulan ini)
  2. **BARU:** `_TodayAttendanceCard` — jam masuk & jam pulang hari ini secara real-time
  3. `_GradesSummaryCard` — tabel nilai sekarang 3 kolom: Mata Pelajaran | UTS | UAS
  4. **BARU:** `_LeaveRequestsCard` — 5 pengajuan izin/sakit terbaru + status badge (Menunggu/Disetujui/Ditolak)

#### Status

- `flutter analyze --no-fatal-infos` → **0 issues**
- `npx tsc --noEmit` → **0 errors**
- Commit push: `github.com/Keroo0/ambis-attendance` (`ccfebc7`) dan `github.com/Keroo0/ambis-admin` (`b48b7dc`)
