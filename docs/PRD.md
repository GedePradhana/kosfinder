# PRD — KosFinder v1

> Platform Android (Flutter + Supabase) · versi 1
> Dibuat: 2026-11-19

---

## 1. Masalah & Tujuan

**Masalah:** Informasi kos tersebar di WhatsApp, media sosial, dan mulut ke mulut sehingga pencari kos sulit membandingkan pilihan dan pemilik kos sulit menjangkau calon penyewa secara efisien.

| Tujuan | Metrik sukses v1 |
|--------|-----------------|
| Satu tempat untuk temukan kos | Seluruh kos yang tersimpan di database berhasil dimuat dan tampil lengkap di aplikasi tanpa pagination/infinite scroll |
| Pemilik bisa kelola info secara mandiri | Pemilik dapat melakukan alur CRUD (tambah, lihat, ubah, hapus) kos miliknya hingga data tersimpan di Supabase |
| Pencari bisa bandingkan pilihan | Daftar, detail, dan filter harga berjalan 100% tanpa login |
| Info selalu terkini | Perubahan status ketersediaan (Tersedia/Penuh) oleh pemilik ter-update seketika di database |

---

## 2. Pengguna

| Peran | Deskripsi | Auth |
|-------|-----------|------|
| **Pencari Anonim** | Mahasiswa/masyarakat yang mencari dan menjelajah info kos | Tanpa login |
| **Pemilik Kos** | Pemilik properti kos yang mempromosikan dan mengelola kos miliknya | Wajib registrasi & login (email & password). Semua akun terdaftar adalah pemilik kos |

---

## 3. Scope Versi 1

### ✅ Masuk

- Lihat daftar kos tanpa login, diurutkan dari yang terbaru (tanpa pagination atau infinite scroll)
- Lihat detail kos: nama, alamat, harga/bulan, jenis (putra/putri/campur), fasilitas (checklist tetap: AC, WiFi, kamar mandi dalam, parkir, dapur bersama), deskripsi, jumlah kamar tersedia, kontak WhatsApp, status (Tersedia/Penuh)
- Cari kos berdasarkan nama atau teks area (kelurahan/kecamatan/kota)
- Filter harga dengan rentang min–maks bebas
- Registrasi & login via email dan password (konfirmasi email dimatikan di Supabase Auth)
- Pemilik: tambah, edit, hapus kos miliknya sendiri (tanpa approval)
- Pemilik: update status ketersediaan kamar secara manual
- Pemilik: satu akun boleh mengelola banyak kos

### ❌ Tidak Masuk v1

Fitur favorit / simpan kos · pembayaran online · chat · ulasan & rating · rekomendasi AI · verifikasi identitas pemilik · upload foto · peta digital/GPS · notifikasi push · filter selain harga · pagination / infinite scroll

---

## 4. Non-Functional Requirements (NFR)

| Kategori | Syarat | Cara uji |
|----------|--------|----------|
| **Keamanan** | RLS (Row Level Security) Supabase membatasi edit/hapus hanya untuk pemilik data | Eksekusi update/delete record kos dengan token user lain → data tidak berubah di database |
| **Keamanan** | Password di-hash oleh Supabase Auth; tidak disimpan plaintext | Periksa kolom password pada tabel `auth.users` di Supabase |
| **Keandalan** | Aplikasi menampilkan pesan error yang ramah (bukan crash) saat koneksi gagal | Matikan koneksi internet → akses daftar kos → pesan error & tombol coba lagi tampil |
| **Performa** | Halaman daftar kos memuat data < 3 detik pada koneksi 4G normal | Ukur durasi fetch hingga render menggunakan Flutter DevTools |
| **Kemudahan pakai** | Alur tambah kos baru selesai dalam ≤ 5 tap setelah pemilik login | Hitung jumlah tap dari layar utama pemilik hingga form kos tersimpan |
| **Privasi** | Nomor kontak WhatsApp pemilik hanya tampil di halaman detail, tidak dimuat pada daftar ringkasan | Inspeksi payload respons query daftar kos di Supabase |

---

## 5. User Stories & Acceptance Criteria

### US01 — Lihat daftar kos
> Sebagai **pencari anonim**, saya ingin melihat daftar kos tanpa login, agar saya bisa mulai mencari tanpa hambatan.

- **US01-AC1** · Given aplikasi dibuka tanpa akun, When halaman beranda dimuat, Then daftar kos tampil dengan nama, harga, jenis, dan status ketersediaan.
- **US01-AC2** · Given kos ada di database, When halaman beranda dimuat, Then daftar kos diurutkan berdasarkan yang terbaru di atas.
- **US01-AC3** · Given belum ada kos di database, When halaman beranda dimuat, Then tampil pesan "Belum ada kos yang terdaftar" (bukan layar kosong).
- **US01-AC4** · Given koneksi internet mati, When halaman beranda dimuat, Then tampil pesan error koneksi dan tombol "Coba lagi".

---

### US02 — Lihat detail kos
> Sebagai **pencari anonim**, saya ingin melihat detail lengkap sebuah kos, agar saya bisa memutuskan apakah sesuai kebutuhan.

- **US02-AC1** · Given kos ada di database, When saya tap salah satu kos di daftar, Then halaman detail tampil: nama, alamat, harga, jenis, fasilitas (AC, WiFi, kamar mandi dalam, parkir, dapur bersama), deskripsi, jumlah kamar, kontak WA, dan status.
- **US02-AC2** · Given koneksi putus saat buka detail, When halaman detail gagal dimuat, Then tampil pesan error — bukan layar putih — dengan tombol "Coba lagi".

---

### US03 — Cari kos
> Sebagai **pencari anonim**, saya ingin mencari kos berdasarkan nama atau area (teks bebas), agar saya menemukan kos di lokasi yang saya inginkan.

- **US03-AC1** · Given saya ketik "Tembalang" di kolom cari, When hasil muncul, Then hanya kos yang nama atau alamatnya mengandung kata "Tembalang" yang ditampilkan.
- **US03-AC2** · Given kata kunci tidak cocok dengan kos mana pun, When hasil muncul, Then tampil pesan "Kos tidak ditemukan" (bukan daftar kosong tanpa keterangan).

---

### US04 — Filter harga
> Sebagai **pencari anonim**, saya ingin menyaring kos berdasarkan rentang harga, agar saya tidak perlu melihat kos di luar anggaran saya.

- **US04-AC1** · Given saya input harga min 500.000 dan maks 1.000.000, When filter diterapkan, Then hanya kos dengan harga dalam rentang tersebut yang tampil.
- **US04-AC2** · Given saya input harga min lebih besar dari maks, When saya tap "Terapkan", Then tampil pesan validasi "Harga minimum tidak boleh lebih besar dari harga maksimum".

---

### US05 — Registrasi & login pemilik kos
> Sebagai **pemilik kos**, saya ingin mendaftar dan login dengan email serta password, agar saya dapat mengelola data kos milik saya.

- **US05-AC1** · Given saya isi email valid dan password ≥ 8 karakter saat registrasi (konfirmasi email dimatikan), When saya tap "Daftar", Then akun pemilik dibuat dan saya langsung masuk ke aplikasi.
- **US05-AC2** · Given saya isi email yang sudah terdaftar, When saya tap "Daftar", Then tampil pesan "Email sudah digunakan".
- **US05-AC3** · Given saya memasukkan email dan password yang benar, When saya tap "Login", Then autentikasi berhasil dan saya masuk ke halaman pengelolaan kos.
- **US05-AC4** · Given saya memasukkan password yang salah, When saya tap "Login", Then proses login gagal dan tampil pesan error "Email atau password salah".

---

### US06 — Tambah kos
> Sebagai **pemilik kos**, saya ingin menambahkan informasi kos saya, agar calon penyewa bisa menemukan kos saya di aplikasi.

- **US06-AC1** · Given saya login sebagai pemilik dan mengisi lengkap semua 8 field wajib (Nama kos, Alamat lengkap, Harga per bulan, Fasilitas pilihan checklist, Deskripsi kos, Jumlah kamar tersedia, Nomor WhatsApp pemilik, dan Jenis kos), When saya tap "Simpan", Then kos baru tersimpan dan langsung tampil di daftar publik.
- **US06-AC2** · Given saya mengosongkan salah satu dari 8 field wajib tersebut, When saya tap "Simpan", Then form menampilkan pesan validasi pada field yang belum diisi dan data tidak disimpan.

---

### US07 — Edit & hapus kos sendiri
> Sebagai **pemilik kos**, saya ingin mengubah atau menghapus informasi kos milik saya, agar data selalu akurat.

- **US07-AC1** · Given saya login sebagai pemilik A dan mencoba mengubah atau menghapus kos milik pemilik B, When request dijalankan, Then tombol aksi tidak tampil di UI dan melalui RLS Supabase data tidak berubah di database.
- **US07-AC2** · Given saya tap "Hapus" pada kos milik saya, When konfirmasi saya setujui, Then kos terhapus dari daftar publik secara permanen.

---

### US08 — Update status ketersediaan
> Sebagai **pemilik kos**, saya ingin mengubah status kos menjadi "Penuh" atau "Tersedia", agar pencari kos tahu ketersediaan kamar terkini.

- **US08-AC1** · Given kos berstatus "Tersedia", When saya ubah ke "Penuh" dan simpan, Then status tersimpan dan kos tetap tampil di daftar publik dengan label "Penuh".
- **US08-AC2** · Given koneksi internet putus saat saya simpan perubahan status, When request gagal, Then tampil pesan error dan status ketersediaan pada data tidak berubah.
