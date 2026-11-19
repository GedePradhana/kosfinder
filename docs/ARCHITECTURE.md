# Architecture — KosFinder v1

> Pola Arsitektur: Screen – Provider – Repository – Supabase  
> Target Platform: Android (Flutter SDK) · Database & Auth: Supabase

---

## 1. Komponen Aplikasi & Tugas (Screen – Provider – Repository – Supabase)

Arsitektur KosFinder menggunakan pemisahan tanggung jawab 4 lapis yang sederhana dan modular:

1. **Screen (Presentation Layer):**
   - Menampilkan UI, menerima input pengguna, dan memicu aksi.
   - Mengamati (*listen/watch*) perubahan state dari Provider.
   - Relevansi: Seluruh user story (`US01` – `US08`).
2. **Provider (State Management Layer):**
   - Mengelola state UI (loading, success, error, daftar kos terpilih, filter aktif).
   - Memanggil fungsi pada Repository dan memberitahu Screen via `notifyListeners()`.
   - `KosProvider`: Mengelola daftar kos publik, pencarian, filter, dan detail kos (`US01`, `US02`, `US03`, `US04`).
   - `OwnerKosProvider`: Mengelola kos milik pemilik yang sedang login (CRUD & status kamar) (`US06`, `US07`, `US08`).
   - `AuthProvider`: Mengelola sesi login, pendaftaran pemilik, dan logout (`US05`).
3. **Repository (Data Access Layer):**
   - Mengabstraksi komunikasi data antara aplikasi dan Supabase Client.
   - Melakukan pemetaan (*mapping*) dari JSON/Map Supabase ke model objek Dart (`KosModel`).
   - `KosRepository`: Mengambil data kos publik dan filter/pencarian (`US01` – `US04`).
   - `OwnerKosRepository`: Mengirim mutasi data kos (insert, update, delete, update status) (`US06` – `US08`).
   - `AuthRepository`: Memanggil Supabase GoTrue API untuk signUp, signIn, dan signOut (`US05`).
4. **Supabase (Backend as a Service):**
   - Menyediakan PostgreSQL database, autentikasi berbasis JWT, dan otorisasi data berbasis Row Level Security (RLS).
   - Relevansi: Seluruh user story (`US01` – `US08`).

---

## 2. Daftar Layar & Alur Navigasi

### Daftar Layar
- **HomeScreen:** Menampilkan daftar kos publik terbaru, search bar, tombol filter harga, dan tombol navigasi ke Auth/Owner (`US01`, `US03`).
- **DetailKosScreen:** Menampilkan detail lengkap sebuah kos beserta kontak WhatsApp pemilik (`US02`).
- **FilterModal / FilterDialog:** Dialog input rentang harga minimum dan maksimum (`US04`).
- **LoginScreen:** Form login email & password untuk pemilik kos (`US05`).
- **RegisterScreen:** Form registrasi email & password untuk pemilik kos baru (`US05`).
- **OwnerDashboardScreen:** Menampilkan daftar kos milik pemilik yang sedang login, tombol switch status (Tersedia/Penuh), tombol edit, hapus, tambah, dan logout (`US07`, `US08`).
- **KosFormScreen:** Form tambah dan ubah data kos (8 field wajib & checklist fasilitas) (`US06`, `US07`).
- **AboutScreen:** Halaman informasi pengembang (`2415051030 - I Gede Pradhana Subawa Deningrat`).

### Alur Navigasi
```
[HomeScreen] ──────── (Tap Card) ────────► [DetailKosScreen]
      │
      ├─────── (Tap Filter) ─────► [FilterDialog]
      │
      ├─────── (Tap Info) ───────► [AboutScreen]
      │
      └─────── (Tap "Area Pemilik") ───► [LoginScreen] ◄──► [RegisterScreen]
                                                │ (Login Sukses)
                                                ▼
                                    [OwnerDashboardScreen]
                                          │         │
                   (Tap "Tambah Kos") ────┤         ├──── (Tap "Edit Kos")
                                          ▼         ▼
                                        [KosFormScreen]
```

---

## 3. Rencana Database & Aturan Akses (RLS)

### Skema Tabel: `kos`
| Kolom | Tipe Data | Keterangan / Validasi |
|-------|-----------|------------------------|
| `id` | `UUID` | Primary Key, default: `gen_random_uuid()` |
| `owner_id` | `UUID` | Foreign Key ke `auth.users(id)` ON DELETE CASCADE |
| `name` | `TEXT` | Nama kos (wajib diisi / NOT NULL) |
| `address` | `TEXT` | Alamat lengkap kos (wajib diisi / NOT NULL) |
| `price_per_month` | `BIGINT` | Harga sewa per bulan bertipe angka (wajib, min: 0) |
| `type` | `TEXT` | Jenis kos: `'putra'`, `'putri'`, atau `'campur'` |
| `facilities` | `TEXT[]` | Checklist fasilitas: AC, WiFi, kamar mandi dalam, parkir, dapur bersama |
| `description` | `TEXT` | Deskripsi kos (wajib diisi / NOT NULL) |
| `available_rooms`| `INT` | Jumlah kamar tersedia bertipe angka (wajib, min: 0) |
| `whatsapp_number`| `TEXT` | Nomor kontak WhatsApp pemilik (wajib diisi / NOT NULL) |
| `is_available` | `BOOLEAN` | `true` = Tersedia, `false` = Penuh (default: `true`) |
| `created_at` | `TIMESTAMPTZ`| Waktu pembuatan data (default: `now()`) |
| `updated_at` | `TIMESTAMPTZ`| Waktu update data terakhir (default: `now()`) |

### Aturan Akses (Row Level Security - RLS)
1. **Melihat (SELECT):**
   - **Publik / Anonim:** Boleh melihat seluruh data kos (`true`). Diurutkan `created_at DESC` di sisi client (`US01`). Nomor WhatsApp hanya diambil/ditampilkan saat membuka detail (`US02`).
2. **Menambah (INSERT):**
   - **Hanya Pemilik Terautentikasi:** Hanya user login yang dapat menambah kos (`auth.uid() = owner_id`) (`US06`).
3. **Mengubah (UPDATE):**
   - **Hanya Pemilik Terkait:** User hanya dapat mengubah data jika `auth.uid() = owner_id`. Jika bukan pemilik, RLS menolak mutasi sehingga data tidak berubah (`US07`, `US08`).
4. **Menghapus (DELETE):**
   - **Hanya Pemilik Terkait:** User hanya dapat menghapus baris jika `auth.uid() = owner_id` (`US07`).

---

## 4. Konfigurasi Lingkungan (`--dart-define`)

Untuk menjamin keamanan dan kepatuhan AGENTS.md (tanpa hardcoded keys), URL dan Public Anon Key Supabase diinjeksikan saat waktu kompilasi (*compile-time*) menggunakan `--dart-define`:

```dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError('SUPABASE_URL dan SUPABASE_ANON_KEY wajib disertakan via --dart-define.');
    }
  }
}
```

Menjalankan aplikasi secara lokal:
```bash
flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=ey...
```

---

## 5. Cara Rilis (Build APK & GitHub Release)

1. **Build APK Release:**
   Build APK biner Android yang mandiri dengan menyertakan variabel environment:
   ```bash
   flutter build apk --release \
     --dart-define=SUPABASE_URL=https://xyz.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=ey...
   ```
   Biner APK release yang dihasilkan berlokasi di:
   `build/app/outputs/flutter-apk/app-release.apk`
2. **Publikasi ke GitHub Release:**
   - Buat Git Tag versi: `git tag v1.0.0`
   - Dorong tag ke remote: `git push origin v1.0.0`
   - Buat Release baru pada repository `https://github.com/GedePradhana/kosfinder.git` dan unggah file `app-release.apk` sebagai aset rilis.

---

## 6. Daftar Package yang Dibutuhkan

Sesuai prinsip kesederhanaan dan kepatuhan AGENTS.md, dependensi dibatasi seminimal mungkin:

| Package | Alasan & Kebutuhan Story |
|---------|--------------------------|
| `provider` | State management standar aplikasi untuk memisahkan UI, logika bisnis, dan data (`US01` – `US08`). |
| `supabase_flutter` | SDK resmi untuk interaksi dengan Supabase Database, Auth, dan session management (`US01` – `US08`). |
| `url_launcher` | Membuka link WhatsApp (`https://wa.me/...`) langsung ke aplikasi WhatsApp atau browser saat calon penyewa menekan kontak pemilik (`US02`). |
| `intl` | Memformat tampilan harga rupiah (misal: `Rp 1.000.000 / bulan`) secara rapi dan standar pada UI (`US01`, `US02`, `US04`). |
