# Phase 3 — Real Data Integration

**Tanggal:** 2026-05-04
**Proyek:** AMBIS Attendance — SMAN 07 Kabupaten Tangerang

---

## Ruang Lingkup

Mengganti data dummy di tiga fitur dengan data nyata dari Drift (SQLite lokal) dan Supabase Storage. FCM notifications tidak termasuk dalam phase ini.

| Fitur | Sebelum | Sesudah |
|---|---|---|
| Nilai (Grades) | `dummy_grades.dart` hardcoded | Drift → `grades` table + seed otomatis |
| Riwayat Kehadiran | `dummy_history.dart` hardcoded | Drift → `attendance` + `leave_requests` table |
| Pengajuan Izin | Form dummy, upload palsu | Image picker → compress → Supabase Storage → Drift |

---

## Dependency Baru

```yaml
# pubspec.yaml — tambahkan di bawah flutter_image_compress
image_picker: ^1.1.0
```

Konfigurasi platform:
- **Android**: tambah `READ_MEDIA_IMAGES` + `READ_EXTERNAL_STORAGE` di `AndroidManifest.xml`
- **iOS**: tambah `NSPhotoLibraryUsageDescription` di `Info.plist`

---

## Arsitektur

```
Drift (SQLite lokal)
  ├─ grades table       ← GradeRepository → gradesProvider → GradesScreen
  ├─ attendance table   ← AttendanceHistoryRepository → historyProvider → HistoryScreen
  └─ leave_requests     ← LeaveRepository → leaveProvider → LeaveRequestScreen
                                    ↑
                          Supabase Storage (attachment upload)
```

Semua screen tetap menampilkan UI yang sama — hanya sumber data yang berubah dari konstanta hardcoded ke Riverpod provider.

---

## Komponen

### 1. `GradeRepository` (BARU)

**File:** `lib/features/grades/data/repositories/grade_repository.dart`

```
getGradesByStudent(studentId, semester) →
  SELECT * FROM grades WHERE student_id = ? AND semester = ?
  GROUP BY subject → SubjectGrade {subject, utsScore, uasScore, tugasScore}
  return (List<SubjectGrade>, GradeSummary)

seedIfEmpty(studentId) →
  if COUNT(*) FROM grades WHERE student_id = ? == 0:
    INSERT 10 baris data dummy (sama seperti dummy_grades.dart sekarang)
  — idempotent, tidak akan duplikasi
```

**Model lokal (bukan Drift entity):**

```dart
class SubjectGrade {
  final String subject;
  final double utsScore, uasScore, tugasScore;
  double get average => (utsScore + uasScore + tugasScore) / 3;
}

class GradeSummary {
  final double overallAverage;
  final String predikat;    // A/B+/B/C+/C/D
  final int rank;           // hardcode 5 sampai admin UI selesai
  final int totalStudents;  // hardcode 32 sampai admin UI selesai
}
```

Predikat: ≥90→A, ≥85→B+, ≥80→B, ≥75→C+, ≥70→C, lainnya→D.

Rank dan totalStudents di-hardcode untuk sementara — akan dihitung nyata di Phase 4 saat admin sudah bisa input nilai semua siswa.

---

### 2. `gradesProvider` (BARU)

**File:** `lib/features/grades/presentation/providers/grades_provider.dart`

```dart
// FutureProvider.family — satu provider per semester (1 atau 2)
final gradesProvider = FutureProvider.family<(List<SubjectGrade>, GradeSummary), int>(
  (ref, semester) async {
    final user = ref.watch(authProvider).valueOrNull;
    if (user == null) return (<SubjectGrade>[], GradeSummary.empty());
    final repo = ref.watch(gradeRepositoryProvider);
    await repo.seedIfEmpty(user.id);
    return repo.getGradesByStudent(user.id, semester);
  },
);
```

---

### 3. `GradesScreen` (DIMODIFIKASI)

**File:** `lib/features/grades/presentation/screens/grades_screen.dart`

- Ubah dari `StatelessWidget` ke `ConsumerWidget`
- Ganti `kDummyGradesSem1/2` → `ref.watch(gradesProvider(1))` / `ref.watch(gradesProvider(2))`
- Tambah loading state: `CircularProgressIndicator` di tengah
- Tambah error state: pesan error + tombol retry
- Tambah empty state: "Nilai belum tersedia"
- Hapus import `dummy_grades.dart`
- Ganti `DummySubjectGrade` → `SubjectGrade`, `DummySummary` → `GradeSummary`

---

### 4. `AttendanceHistoryRepository` (BARU)

**File:** `lib/features/history/data/repositories/attendance_history_repository.dart`

```
getMonthRecords(studentId, year, month) →
  rows = SELECT * FROM attendance
         WHERE student_id=? AND date LIKE '{year}-{mm}-%'

  leaves = SELECT * FROM leave_requests
           WHERE student_id=? AND status='approved'
           AND date_from <= '{year}-{mm}-{last_day}'
           AND date_to   >= '{year}-{mm}-01'

  untuk setiap hari Senin–Jumat di bulan tersebut:
    key = 'YYYY-MM-DD'
    jika ada attendance row untuk key ini:
      if time_in <= '07:30' → status = hadir
      if time_in >  '07:30' → status = terlambat
    else if ada approved leave yang cover key ini:
      status = izin
    else if date < today:
      status = alfa
    — hari yang belum lewat (masa depan) tidak dimasukkan

  return List<AttendanceDay>
```

**Model lokal:**

```dart
enum AttendanceStatus { hadir, terlambat, izin, alfa }

class AttendanceDay {
  final DateTime date;
  final AttendanceStatus status;
  final String? checkInTime;   // format 'HH:mm'
  final String? checkOutTime;  // format 'HH:mm'
}
```

---

### 5. `historyProvider` (BARU)

**File:** `lib/features/history/presentation/providers/history_provider.dart`

```dart
// FutureProvider.family keyed by (year, month)
final historyProvider = FutureProvider.family<List<AttendanceDay>, (int, int)>(
  (ref, key) async {
    final (year, month) = key;
    final user = ref.watch(authProvider).valueOrNull;
    if (user == null) return [];
    return ref.watch(attendanceHistoryRepositoryProvider)
        .getMonthRecords(user.id, year, month);
  },
);
```

---

### 6. `HistoryScreen` (DIMODIFIKASI)

**File:** `lib/features/history/presentation/screens/history_screen.dart`

- Ubah ke `ConsumerStatefulWidget`
- Ganti `DummyAttendanceRecord` → `AttendanceDay` di semua widget internal
- Watch `historyProvider((_displayMonth.year, _displayMonth.month))`
- Saat `_displayMonth` berubah (prev/next), provider otomatis rebuild karena family key berubah
- Tambah loading state (overlay spinner di atas kalender)
- Tambah error state
- Hapus import `dummy_history.dart`

---

### 7. `LeaveRepository` (BARU)

**File:** `lib/features/leave_request/data/repositories/leave_repository.dart`

```
submitLeave({studentId, type, reason, dateFrom, dateTo, File imageFile}) →
  1. Validasi ekstensi: path harus berakhir .jpg atau .jpeg
     → throw LeaveException('Format file harus JPG.')
  2. Compress: FlutterImageCompress.compressWithFile(
       path, minWidth: 1080, minHeight: 1080, quality: 85, format: JPEG)
     → jika hasil > 1MB: ulangi dengan quality: 60
     → jika masih > 1MB: throw LeaveException('File terlalu besar.')
  3. Upload ke Supabase Storage:
       bucket: 'leave-attachments'
       path:   '{studentId}/{uuid}.jpg'
     → dapat attachmentUrl (public URL)
  4. Mapping type ke DB enum:
       'Sakit' → 'sakit'
       'Izin Keluarga' | 'Keperluan Lain' → 'izin'
       (kolom reason menyimpan detail tipe sebenarnya)
  5. Insert ke Drift leave_requests:
       id, studentId, type (mapped), reason, dateFrom (YYYY-MM-DD), dateTo (YYYY-MM-DD),
       attachmentUrl, attachmentLocalPath (path compress hasil),
       status='pending', createdAt=now, updatedAt=now
  6. Return LeaveRequestEntity

getLeavesByStudent(studentId) →
  SELECT * FROM leave_requests
  WHERE student_id=? ORDER BY created_at DESC
```

**Exception baru di `app_exception.dart`:**

```dart
class LeaveException extends AppException {
  const LeaveException(super.message);
}
```

---

### 8. `leaveProvider` (BARU)

**File:** `lib/features/leave_request/presentation/providers/leave_provider.dart`

```dart
class LeaveNotifier extends Notifier<AsyncValue<List<LeaveRequestEntity>>> {
  @override
  AsyncValue<List<LeaveRequestEntity>> build() {
    // load on build
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async { ... }

  Future<void> submit({
    required String type,
    required String reason,
    required DateTime dateFrom,
    required DateTime dateTo,
    required File imageFile,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authProvider).valueOrNull!;
      await ref.read(leaveRepositoryProvider).submitLeave(...);
      await _load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final leaveProvider = NotifierProvider<LeaveNotifier, AsyncValue<List<LeaveRequestEntity>>>(
  LeaveNotifier.new,
);
```

---

### 9. `LeaveRequestScreen` (DIMODIFIKASI)

**File:** `lib/features/leave_request/presentation/screens/leave_request_screen.dart`

- Ubah ke `ConsumerStatefulWidget`
- Tambah `File? _imageFile` di state (ganti `String? _selectedFileName`)
- Upload button → `ImagePicker().pickImage(source: ImageSource.gallery)`
  - Setelah pick: validasi ekstensi di UI layer juga (snackbar jika bukan jpg)
  - Tampilkan nama file yang dipilih
- Submit button:
  - Guard: `_imageFile == null` → snackbar "Foto bukti wajib diupload"
  - Panggil `ref.read(leaveProvider.notifier).submit(...)`
  - Tampilkan loading overlay selama proses
  - Sukses → tutup loading, tampilkan dialog "Pengajuan Terkirim" (sama seperti sekarang)
  - Error → tutup loading, snackbar dengan pesan error
- Riwayat list: `ref.watch(leaveProvider)` dengan loading/error/empty state
- Hapus import `dummy_leaves.dart`, hapus `DummyLeaveRequest`

---

## Supabase Storage Setup

Buat bucket `leave-attachments` di Supabase dashboard:
- **Public**: tidak (private bucket)
- **Allowed MIME types**: `image/jpeg`
- **Max file size**: 1048576 bytes (1 MB)

RLS policy (upload): authenticated user hanya bisa upload ke path yang dimulai dengan `{auth.uid()}/`.

---

## File yang Diubah / Dibuat

| File | Aksi |
|---|---|
| `pubspec.yaml` | MODIFIKASI — tambah `image_picker: ^1.1.0` |
| `android/app/src/main/AndroidManifest.xml` | MODIFIKASI — permission galeri |
| `ios/Runner/Info.plist` | MODIFIKASI — NSPhotoLibraryUsageDescription |
| `lib/core/exceptions/app_exception.dart` | MODIFIKASI — tambah `LeaveException` |
| `lib/features/grades/data/repositories/grade_repository.dart` | BUAT |
| `lib/features/grades/presentation/providers/grades_provider.dart` | BUAT |
| `lib/features/grades/presentation/screens/grades_screen.dart` | MODIFIKASI |
| `lib/features/grades/data/dummy_grades.dart` | HAPUS |
| `lib/features/history/data/repositories/attendance_history_repository.dart` | BUAT |
| `lib/features/history/presentation/providers/history_provider.dart` | BUAT |
| `lib/features/history/presentation/screens/history_screen.dart` | MODIFIKASI |
| `lib/features/history/data/dummy_history.dart` | HAPUS |
| `lib/features/leave_request/data/repositories/leave_repository.dart` | BUAT |
| `lib/features/leave_request/presentation/providers/leave_provider.dart` | BUAT |
| `lib/features/leave_request/presentation/screens/leave_request_screen.dart` | MODIFIKASI |
| `lib/features/leave_request/data/dummy_leaves.dart` | HAPUS |

---

## Di Luar Ruang Lingkup

- FCM / push notification ke orang tua (Phase 4)
- Rank dan total siswa nyata di summary nilai (Phase 4 — admin input nilai semua siswa)
- Approval leave request oleh guru (Phase 4 — admin dashboard)
- Supabase Realtime subscription untuk status izin real-time (Phase 4)
- Auto-retry upload jika koneksi terputus saat submit izin
