# TASKS — KosFinder v1

Dokumen rencana kerja teknis menggunakan pendekatan **Vertical Slice Architecture**. Setiap slice menghasilkan aplikasi yang langsung dapat dijalankan (*runnable*) dan diuji.

Format per task:
`| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |`

---

## Slice 0: Fondasi Proyek & Konfigurasi Dasar

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T01** | Konfigurasi dependensi dasar, model data `KosModel`, dan inisialisasi environment config (`AppConfig`) dari `--dart-define` | Fondasi `US01` – `US08` | `pubspec.yaml`, `lib/core/app_config.dart`, `lib/models/kos_model.dart`, `test/models/kos_model_test.dart` | Jalankan `flutter test test/models/kos_model_test.dart` untuk verifikasi parsing JSON | `completed` |
| **T02** | Buat halaman About yang menampilkan identitas pengembang dan tombol navigasi dari halaman awal | Kepatuhan `AGENTS.md` (DoD & Identitas Pengembang) | `lib/screens/about_screen.dart`, `lib/main.dart` | Jalankan aplikasi di browser/device, buka layar About, pastikan tampil teks `2415051030 - I Gede Pradhana Subawa Deningrat` | `completed` |

---

## Slice 1: Daftar dan Detail Kos (Pencari Anonim)

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T03** | Implementasi `KosRepository` dan `KosProvider` untuk memuat daftar kos publik urut terbaru dari Supabase | `US01-AC1`, `US01-AC2`, `US01-AC3`, `US01-AC4` | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart` | Jalankan unit test `test/providers/kos_provider_test.dart` dengan mock/dummy data | `completed` |
| **T04** | Buat layar `HomeScreen` untuk menampilkan daftar kartu kos dengan status ketersediaan (Tersedia/Penuh) sebagai teks, kondisi data kosong, indikator loading, dan penanganan error/retry | `US01-AC1`, `US01-AC2`, `US01-AC3`, `US01-AC4` | `lib/screens/home_screen.dart`, `lib/widgets/kos_card.dart`, `lib/main.dart` | Jalankan aplikasi, verifikasi daftar kos muncul urut terbaru beserta teks status ketersediaan, pesan kosong tampil bila DB kosong, dan pesan error muncul saat offline | `completed` |
| **T05** | Buat layar `DetailKosScreen` untuk menampilkan 9 informasi lengkap kos (termasuk status ketersediaan) dan integrasi tombol WhatsApp via `url_launcher` | `US02-AC1`, `US02-AC2` | `lib/screens/detail_kos_screen.dart`, `lib/screens/home_screen.dart` | Tap salah satu kos di `HomeScreen`, verifikasi ke-9 informasi (termasuk status) tampil lengkap, tap tombol WhatsApp untuk memicu url_launcher | `completed` |

---

## Slice 2: Pencarian dan Filter Harga (Pencari Anonim)

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T06** | Tambahkan fitur pencarian teks bebas (nama kos atau area alamat) pada `KosProvider` dan `KosRepository` | `US03-AC1`, `US03-AC2` | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `lib/screens/home_screen.dart` | Ketik nama area di search bar `HomeScreen`, verifikasi daftar tersaring sesuai kata kunci, dan muncul pesan "Kos tidak ditemukan" bila tidak ada hasil | `completed` |
| **T07** | Implementasi dialog filter harga min-maks dengan validasi input dan integrasi ke daftar kos | `US04-AC1`, `US04-AC2` | `lib/widgets/filter_dialog.dart`, `lib/providers/kos_provider.dart`, `lib/screens/home_screen.dart` | Buka dialog filter, masukkan min & maks, verifikasi daftar tersaring; masukkan min > maks dan pastikan muncul pesan validasi error | `completed` |

---

## Slice 3: Registrasi dan Login Pemilik Kos

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T08** | Implementasi `AuthRepository` dan `AuthProvider` untuk registrasi, login, logout, dan manajemen session Supabase Auth | `US05-AC1`, `US05-AC2`, `US05-AC3`, `US05-AC4` | `lib/repositories/auth_repository.dart`, `lib/providers/auth_provider.dart` | Jalankan unit test `test/providers/auth_provider_test.dart` untuk verifikasi alur state autentikasi | `completed` |
| **T09** | Buat layar `LoginScreen` dan `RegisterScreen` dengan validasi form (email & password $\ge 8$ karakter) dan penanganan error | `US05-AC1`, `US05-AC2`, `US05-AC3`, `US05-AC4` | `lib/screens/auth/login_screen.dart`, `lib/screens/auth/register_screen.dart`, `lib/screens/home_screen.dart` | Masuk ke menu pemilik dari `HomeScreen`, coba register akun baru, verifikasi pesan email duplikat, uji login password salah, dan login sukses | `completed` |

---

## Slice 4: Pengelolaan Kos Milik Sendiri (CRUD Pemilik)

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T10** | Implementasi `OwnerKosRepository` dan `OwnerKosProvider` untuk CRUD data kos terikat `owner_id` akun login | `US06-AC1`, `US06-AC2`, `US07-AC1`, `US07-AC2` | `lib/repositories/owner_kos_repository.dart`, `lib/providers/owner_kos_provider.dart` | Jalankan unit test `test/providers/owner_kos_provider_test.dart` untuk verifikasi isolasi state kos milik pemilik | `completed` |
| **T11** | Buat layar `OwnerDashboardScreen` untuk melihat daftar kos milik pemilik yang login dan opsi navigasi aksi | `US07-AC1`, `US07-AC2` | `lib/screens/owner/owner_dashboard_screen.dart`, `lib/main.dart` | Login sebagai pemilik, verifikasi dashboard hanya menampilkan kos milik akun aktif dan ada opsi aksi tambah/keluar | `completed` |
| **T12** | Buat layar `KosFormScreen` mode Tambah dengan validasi 8 field wajib dan checklist fasilitas | `US06-AC1`, `US06-AC2` | `lib/screens/owner/kos_form_screen.dart`, `lib/screens/owner/owner_dashboard_screen.dart` | Buka form tambah kos, kosongkan salah satu field lalu simpan (harus muncul validasi), isi lengkap lalu simpan, pastikan data muncul di dashboard dan publik | `pending` |
| **T13** | Implementasi mode Edit dan aksi Hapus pada `KosFormScreen` dan `OwnerDashboardScreen` dengan proteksi RLS | `US07-AC1`, `US07-AC2` | `lib/screens/owner/kos_form_screen.dart`, `lib/screens/owner/owner_dashboard_screen.dart` | Ubah nama/harga kos sendiri dan verifikasi tersimpan; hapus salah satu kos dan verifikasi hilang; pastikan tombol edit/hapus tidak muncul pada kos milik akun lain | `completed` |

---

## Slice 5: Manajemen Ketersediaan Kamar (Bonus)

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T14** | Implementasi switch status ketersediaan (Tersedia/Penuh) pada dashboard pemilik dan penanganan error jaringan | `US08-AC1`, `US08-AC2` | `lib/screens/owner/owner_dashboard_screen.dart`, `lib/providers/owner_kos_provider.dart` | Toggle switch ketersediaan pada kos di dashboard, verifikasi status berubah di DB; matikan internet lalu toggle, pastikan status revert dan muncul pesan error | `completed` |
| **T15** | Memperindah tampilan status ketersediaan menjadi badge berwarna pada `HomeScreen` dan `DetailKosScreen` (opsional/bonus) | `US08-AC1` | `lib/widgets/kos_card.dart`, `lib/screens/detail_kos_screen.dart` | Buka `HomeScreen` dan `DetailKosScreen`, verifikasi status ketersediaan tampil menarik dengan badge berwarna (hijau untuk Tersedia, merah/abu untuk Penuh) | `completed` |
