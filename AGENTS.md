# AGENTS.md — Aturan Kerja Agen AI

Dokumen ini berisi panduan dan aturan baku yang wajib dipatuhi oleh setiap agen AI yang bekerja pada repository proyek **KosFinder**.

---

## 1. Konteks Proyek & Dokumen Acuan

Proyek **KosFinder** adalah aplikasi pencarian dan pengelolaan kos berbasis Android. Setiap pengerjaan fitur atau perbaikan wajib mengacu secara ketat pada dokumen referensi berikut:

- `docs/PRD.md` — Product Requirements Document (kebutuhan produk, scope v1, peran pengguna, user stories, dan acceptance criteria).
- `docs/ARCHITECTURE.md` — Arsitektur sistem, struktur folder, layer aplikasi, dan skema database/RLS.
- `docs/TASKS.md` — Rincian pembagian task implementasi dan status pengerjaannya.

---

## 2. Cara Kerja

- **Satu Task per Permintaan:** Fokus selesaikan satu task spesifik per siklus prompt/permintaan pengguna.
- **Batasan Perubahan File:** Jangan mengubah atau menyentuh file di luar lingkup task yang sedang dikerjakan.
- **Rencana untuk Perubahan Besar:** Buat dan paparkan rencana kerja terlebih dahulu sebelum melakukan refactoring atau perubahan arsitektural berskala besar.
- **Prinsip Kesederhanaan (KISS):** Selalu pilih solusi implementasi yang paling sederhana, mudah dibaca, dan langsung menjawab kebutuhan tanpa overengineering.
- **Izin Penambahan Package:** Dilarang menambahkan dependensi/package baru ke `pubspec.yaml` tanpa persetujuan eksplisit dari pengguna.

---

## 3. Teknologi Utama

- **Framework:** Flutter (Android-focused)
- **State Management:** Provider
- **Backend as a Service:** Supabase (Database PostgreSQL, Authentication, & Row Level Security)

---

## 4. Keamanan & Kredensial

- **Tanpa Hardcoded Secrets:** Dilarang keras menaruh API key, secret, token, atau password langsung di dalam source code (gunakan konfigurasi aman / `.env` yang terabaikan oleh git).
- **Larangan `service_role` Key:** Kunci `service_role` tidak boleh digunakan atau dimasukkan ke dalam aplikasi klien dalam kondisi apa pun (hanya gunakan `anon` key publik).
- **Enforcement Hak Akses:** Penegakan izin akses data (CRUD) wajib dijamin melalui kebijakan **Row Level Security (RLS)** pada level database Supabase, bukan hanya validasi sisi klien.

---

## 5. Standar Git & Commit

- **Granularitas Commit:** Satu task diselesaikan dalam satu commit tersendiri.
- **Format Pesan Commit:** Pesan commit wajib mencantumkan ID task yang relevan (contoh: `feat(T01): inisialisasi struktur provider`, `docs(T03): update panduan setup`).
- **Verifikasi Sebelum Commit:** Pastikan `git status` selalu diperiksa agar tidak ada file rahasia/untracked yang tidak sengaja ter-stage.

---

## 6. Definition of Done (DoD)

Sebuah task dianggap selesai hanya jika memenuhi seluruh kriteria berikut:

1. `flutter analyze` berjalan bersih tanpa error atau warning baru.
2. `flutter test` lulus seluruh pengujian yang ada.
3. Aplikasi berhasil dijalankan dan diverifikasi di device target (desktop/browser/emulator/perangkat fisik).
4. Agen secara transparan melaporkan aspek atau skenario apa saja yang **belum diuji** pada akhir laporan.

---

## 7. Informasi Pengembang (Halaman About)

Pada halaman **About** aplikasi, wajib menampilkan identitas pengembang berikut secara jelas:

- **NIM:** 2415051030
- **Nama:** I Gede Pradhana Subawa Deningrat
- **Format Tampilan:** `2415051030 - I Gede Pradhana Subawa Deningrat`
