# KosFinder (v0.1.0)

Aplikasi pencarian dan pengelolaan kos berbasis Android yang dibangun menggunakan **Flutter** dan **Supabase**.

---

## Deskripsi Singkat

KosFinder hadir untuk mempermudah calon penyewa menemukan hunian kos yang sesuai kebutuhan sekaligus membantu pemilik kos mempromosikan dan memperbarui informasi kamar secara mandiri dan transparan. Calon pencari kos dapat langsung mencari, memfilter rentang harga, dan melihat detail fasilitas tanpa perlu melakukan registrasi atau login akun.

---

## Identitas Pengembang

- **NIM:** 2415051030
- **Nama:** I Gede Pradhana Subawa Deningrat
- **Format di Aplikasi:** `2415051030 - I Gede Pradhana Subawa Deningrat` (Halaman About)

---

## Fitur Utama

### 1. Pencari Kos (Anonim / Tanpa Login)
- **Jelajah Kos:** Melihat seluruh daftar kos publik terbaru dengan status ketersediaan (*badge* hijau **Tersedia** / merah **Penuh**).
- **Pencarian Real-Time:** Menemukan kos berdasarkan nama kos atau area/alamat (kelurahan, kecamatan, kota).
- **Filter Rentang Harga:** Memfilter kos berdasarkan batas harga minimum dan maksimum per bulan. Input otomatis menyaring karakter angka (*digits only*) dan memvalidasi `min <= max`.
- **Detail Lengkap Kos (US02-AC1):** Menampilkan 9 informasi lengkap (nama, alamat, harga/bulan, jenis kos, checklist fasilitas, deskripsi, kamar tersedia, status ketersediaan, serta nomor WhatsApp pemilik) dilengkapi tombol langsung ke WhatsApp melalui `url_launcher`.
- **Privasi Terjaga:** Nomor WhatsApp pemilik diproteksi dan tidak dimuat pada daftar publik, melainkan hanya di-fetch saat halaman detail diakses.

### 2. Pemilik Kos (Autentikasi & Manajemen Properti)
- **Registrasi & Login Akun:** Registrasi akun pemilik kos dengan validasi form (email dan password minimal 6 karakter).
- **Dashboard Pengelolaan:** Melihat daftar properti kos milik sendiri yang terisolasi dengan aman melalui kebijakan *Row Level Security (RLS)* Supabase.
- **Tambah Kos Baru:** Menambahkan properti baru dengan 8 atribut wajib serta pemilihan fasilitas terstandarisasi. Field nomor WhatsApp dilengkapi proteksi format angka (*digits only*, minimal 9 digit).
- **Ubah Data Kos (Edit):** Memperbarui informasi kos yang sudah ada secara mandiri.
- **Hapus Kos:** Menghapus properti kos dengan dialog konfirmasi keamanan.
- **Toggle Status Ketersediaan Cepat:** Mengubah status ketersediaan kamar (Tersedia / Penuh) secara langsung via switch di dashboard dengan penanganan error jaringan/RLS.

---

## Batasan Versi 1 (Scope Boundaries)

Sesuai dokumen spesifikasi *Product Requirements Document (PRD)*, versi 0.1.0 memiliki batasan lingkup berikut:
1. **Tidak Ada Pagination / Infinite Scroll:** Seluruh data kos dimuat langsung dari basis data.
2. **Tanpa Media Gambar/Upload Foto:** Informasi kos belum mendukung unggah foto properti ke Supabase Storage.
3. **Tanpa Integrasi Pembayaran Online & Chat Internal:** Transaksi dan komunikasi langsung diarahkan melalui aplikasi WhatsApp pemilik.
4. **Tanpa Rating, Ulasan, dan Peta Digital (GPS):** Belum mencakup peta interaktif koordinat lokasi atau ulasan pengguna.
5. **Autentikasi Terbatas:** Registrasi dikhususkan untuk peran pemilik kos tanpa sistem verifikasi identitas (KTP) otomatis.

---

## Cara Menjalankan

Aplikasi ini menggunakan parameter `--dart-define` untuk membaca URL dan Public Anon Key Supabase secara aman pada saat kompilasi (*compile-time*), tanpa mengekspos kredensial di dalam kode sumber.

### 1. Menjalankan di Perangkat Target (Debug / Development)

Ganti `<SUPABASE_URL>` dan `<SUPABASE_ANON_KEY>` dengan URL dan Public Anon Key Supabase Anda:

#### PowerShell / Windows Terminal:
```powershell
flutter run -d <device_id> `
  --dart-define=SUPABASE_URL=<SUPABASE_URL> `
  --dart-define=SUPABASE_ANON_KEY=<SUPABASE_ANON_KEY>
```

#### Command Prompt (cmd):
```cmd
flutter run -d <device_id> --dart-define=SUPABASE_URL=<SUPABASE_URL> --dart-define=SUPABASE_ANON_KEY=<SUPABASE_ANON_KEY>
```

#### Web (Chrome):
```bash
flutter run -d chrome --dart-define=SUPABASE_URL=<SUPABASE_URL> --dart-define=SUPABASE_ANON_KEY=<SUPABASE_ANON_KEY>
```

---

### 2. Menjalankan Pengujian (Tests)

```bash
flutter test
```

### 3. Pengecekan Kualitas Kode (Analyze)

```bash
flutter analyze
```

---

### 4. Build APK

#### Build APK Release:
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=<SUPABASE_URL> \
  --dart-define=SUPABASE_ANON_KEY=<SUPABASE_ANON_KEY>
```
Output berkas release: `build/app/outputs/flutter-apk/app-release.apk`.

> **Catatan:** Jika proyek belum dikonfigurasi dengan release signing keystore mandiri, Flutter menggunakan konfigurasi bawaan atau debug signing. Untuk membuat APK debug secara eksplisit:
> ```bash
> flutter build apk --debug \
>   --dart-define=SUPABASE_URL=<SUPABASE_URL> \
>   --dart-define=SUPABASE_ANON_KEY=<SUPABASE_ANON_KEY>
> ```
> Output berkas debug: `build/app/outputs/flutter-apk/app-debug.apk`.
