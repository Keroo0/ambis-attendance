# Phase 2 — Lapisan Keamanan (Security Layer)

**Tanggal:** 2026-05-03
**Proyek:** AMBIS Attendance — SMAN 07 Kabupaten Tangerang

---

## Ruang Lingkup

Mengimplementasi empat kontrol keamanan Phase 2 di atas alur absensi yang sudah ada. Geofencing 50 m sudah selesai dan tidak termasuk di sini.

| # | Kontrol | Status sebelum |
|---|---|---|
| 1 | Deteksi liveness aktif (kedip mata) | Hanya pengecekan frontal pasif |
| 2 | Deteksi Mock GPS | Stub ada, tapi dinonaktifkan (`if (false &&`) |
| 3 | Fallback setelah 3x gagal wajah | Belum diimplementasi |
| 4 | Rate limiting (cooldown + lockout) | Belum diimplementasi |

---

## Arsitektur

State rate limiting disimpan **in-memory saja** (Riverpod provider). Tidak ada persistensi ke DB — force-close app akan me-reset counter. Ini adalah trade-off yang diterima demi kesederhanaan.

```
AttendanceScreen._start()
  ├─ cek cooldown (RateLimitNotifier) → blokir jika < 30 dtk sejak sukses terakhir
  ├─ cek lockout  (RateLimitNotifier) → blokir jika failCount ≥ 5, dalam 5 menit
  ├─ cek time window (sudah ada)
  ├─ cek GPS + geofence (sudah ada)
  ├─ cek mock GPS (BARU — sebelumnya dinonaktifkan)
  └─ push ScannerScreen
       ├─ FASE LIVENESS
       │    state machine: idle → waitingBlink → passed
       │    deteksi: leftEyeOpenProbability < 0.3 && rightEyeOpenProbability < 0.3
       │    timeout 8 dtk → kegagalan
       └─ FASE PENCOCOKAN WAJAH (sudah ada, hanya dijalankan setelah liveness lolos)
            ├─ sukses → rateLimitProvider.recordSuccess() → go('/dashboard')
            └─ gagal  → rateLimitProvider.recordFailure()
                        _failCount++
                        _failCount ≥ 3 → tampilkan dialog fallback
```

---

## Komponen

### 1. `RateLimitNotifier` (BARU)

**File:** `lib/features/attendance/presentation/providers/rate_limit_provider.dart`

```
State:
  DateTime? lastSuccess   — timestamp absen berhasil terakhir
  int       failCount     — jumlah kegagalan berturutan dalam sesi ini
  DateTime? lockedUntil   — diset ketika failCount mencapai 5

Method:
  int cooldownSecondsLeft()  → max(0, 30 - detik sejak lastSuccess)
  int lockSecondsLeft()      → max(0, lockedUntil - sekarang, dalam detik)
  void recordSuccess()       → lastSuccess = now, failCount = 0, lockedUntil = null
  void recordFailure()       → failCount++; jika failCount >= 5: lockedUntil = now + 5 menit
```

Dicakup secara global (bukan family) — satu instance per sesi app, dibagi antara `AttendanceScreen` dan `ScannerScreen`.

---

### 2. `ScannerScreen` (DIMODIFIKASI)

**File:** `lib/features/attendance/presentation/screens/scanner_screen.dart`

**State machine liveness:**

```dart
enum _LivenessState { idle, waitingBlink, passed }
```

- Saat kamera siap: state = `waitingBlink`, mulai `Timer` 8 detik
- Setiap frame: jika `leftEyeOpenProbability < 0.3 && rightEyeOpenProbability < 0.3`
  → batalkan timer, state = `passed`, langsung mulai loop pencocokan wajah
- Timer habis sebelum kedip → `_handleFailure('Kedipan tidak terdeteksi')`

**Perubahan `FaceDetectorOptions`:**
```dart
enableClassification: true   // sebelumnya false — wajib untuk eyeOpenProbability
```

**Counter kegagalan:**
- `int _failCount = 0` di state widget
- `_handleFailure()`: `_failCount++`, panggil `rateLimitProvider.recordFailure()`
  - Jika `_failCount >= 3`: hentikan loop, tampilkan dialog fallback
  - Selain itu: mulai ulang state machine liveness, tampilkan pesan coba lagi

**Dialog fallback (ditampilkan saat _failCount == 3):**
```
Judul:  "Verifikasi Gagal"
Isi:    "Silakan hubungi guru untuk validasi manual kehadiran Anda."
Aksi:   [Coba Lagi]           → reset _failCount = 0, mulai ulang liveness
        [Minta Validasi Guru] → Navigator.pop (kembali ke AttendanceScreen)
```

**Pesan status selama liveness:**
- `waitingBlink` → "Kedipkan mata Anda" (warna amber)
- `passed`       → "Liveness OK, mencocokkan wajah..." (warna primary)
- pesan gagal    → warna error (sudah ada)

---

### 3. `AttendanceScreen` (DIMODIFIKASI)

**File:** `lib/features/attendance/presentation/screens/attendance_screen.dart`

Dua tambahan di `_start()`:

**a) Pengecekan rate limit (sebelum pengecekan time window):**
```dart
final rl = ref.read(rateLimitProvider.notifier);
final cooldown = rl.cooldownSecondsLeft();
if (cooldown > 0) {
  // tampilkan snackbar: "Tunggu {cooldown} detik sebelum absen lagi."
  return;
}
final locked = rl.lockSecondsLeft();
if (locked > 0) {
  final mins = (locked / 60).ceil();
  // tampilkan snackbar: "Terlalu banyak percobaan. Coba lagi dalam {mins} menit."
  return;
}
```

**b) Aktifkan pengecekan mock GPS:**
```dart
// Hapus guard `if (false &&` — baris 58 saat ini:
// if (false && LocationService.isMocked(pos)) {
// Ubah menjadi:
if (LocationService.isMocked(pos)) {
  throw const GeofenceException('Mock GPS terdeteksi.');
}
```

---

### 4. `app_exception.dart` (DIMODIFIKASI)

Tambah dua tipe exception baru:

```dart
class LivenessException extends AppException {
  const LivenessException(super.message);
}

class RateLimitException extends AppException {
  const RateLimitException(super.message);
}
```

`MockGpsException` tidak diperlukan — `GeofenceException` sudah sesuai secara semantik untuk mock GPS (sudah digunakan untuk semua pelanggaran lokasi).

---

## Pesan Error (Bahasa Indonesia)

| Situasi | Pesan |
|---|---|
| Cooldown aktif | "Tunggu {n} detik sebelum absen lagi." |
| Terkunci | "Terlalu banyak percobaan. Coba lagi dalam {n} menit." |
| Mock GPS | "Mock GPS terdeteksi. Nonaktifkan aplikasi pemalsuan lokasi." |
| Liveness timeout | "Kedipan tidak terdeteksi. Coba lagi." |
| Wajah tidak cocok (sudah ada) | "Wajah tidak cocok. Coba lagi dengan pencahayaan lebih baik." |

---

## File yang Diubah

| File | Aksi |
|---|---|
| `lib/features/attendance/presentation/providers/rate_limit_provider.dart` | BUAT |
| `lib/features/attendance/presentation/screens/scanner_screen.dart` | MODIFIKASI |
| `lib/features/attendance/presentation/screens/attendance_screen.dart` | MODIFIKASI |
| `lib/core/exceptions/app_exception.dart` | MODIFIKASI |

---

## Di Luar Ruang Lingkup

- Persistensi state rate limit saat app di-restart (trade-off yang diterima)
- Beberapa jenis tantangan liveness (hanya kedip mata)
- UI validasi guru di sisi admin (Phase 4)
- Notifikasi FCM ke guru saat fallback dipicu (Phase 4)
