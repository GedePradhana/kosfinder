# KosFinder

Aplikasi pencarian dan pengelolaan kos berbasis Android menggunakan Flutter dan Supabase.

---

## Identitas Pengembang

- **NIM:** 2415051030
- **Nama:** I Gede Pradhana Subawa Deningrat
- **Format di Aplikasi:** `2415051030 - I Gede Pradhana Subawa Deningrat` (Halaman About)

---

## Cara Menjalankan

Aplikasi ini menggunakan parameter `--dart-define` untuk membaca URL dan Public Anon Key Supabase secara aman waktu kompilasi (*compile-time*), tanpa menuliskan kredensial di dalam kode sumber.

### 1. Menjalankan di Perangkat Target (Debug / Development)

Ganti `<SUPABASE_URL>` dan `<SUPABASE_ANON_KEY>` dengan URL dan Public Anon Key Supabase Anda:

#### PowerShell / Windows Terminal:
```powershell
flutter run -d chrome `
  --dart-define=SUPABASE_URL=<SUPABASE_URL> `
  --dart-define=SUPABASE_ANON_KEY=<SUPABASE_ANON_KEY>
```

#### Command Prompt (cmd):
```cmd
flutter run -d chrome --dart-define=SUPABASE_URL=<SUPABASE_URL> --dart-define=SUPABASE_ANON_KEY=<SUPABASE_ANON_KEY>
```

#### Android Device / Emulator:
```bash
flutter run -d android --dart-define=SUPABASE_URL=<SUPABASE_URL> --dart-define=SUPABASE_ANON_KEY=<SUPABASE_ANON_KEY>
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

### 4. Build APK Release

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://contoh-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbgciOiAiSFUzNTI1NiIsInR5cCI6ICJKV1QiLCJhbGciOiAiSFMyNTYifQ.contoh_anon_key_palsu_123456
```

Output APK release akan berada di: `build/app/outputs/flutter-apk/app-release.apk`.
