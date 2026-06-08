# Sipadu (Sistem Pengaduan Terpadu UPA TIK)

Sipadu adalah aplikasi sistem pengaduan dan evaluasi terpadu untuk UPA TIK. Aplikasi ini memungkinkan pengguna (mahasiswa maupun civitas akademika) untuk masuk menggunakan akun Google Workspace (akun kampus) guna mengajukan pengaduan secara terintegrasi.

## Persiapan & Menjalankan Aplikasi Lokal

1. Salin file `.env.example` menjadi `.env` dan masukkan konfigurasi Google Client ID & Secret Anda:
   ```bash
   cp .env.example .env
   ```
2. Instal *dependencies* Elixir & Node.js, serta siapkan database:
   ```bash
   mix setup
   ```
3. Jalankan server Phoenix:
   ```bash
   mix phx.server
   ```
   *(Atau jalankan melalui IEx dengan `iex -S mix phx.server`)*

Sekarang Anda bisa mengakses aplikasi melalui browser di [`localhost:4000`](http://localhost:4000).

## Menjalankan dengan Docker

Projek ini telah dilengkapi dengan konfigurasi **Docker** & **Docker Compose** untuk membangun dan menjalankan aplikasi Phoenix (`sipadu`) secara terisolasi. Kita menggunakan mode jaringan `host` agar container aplikasi dapat mengakses database PostgreSQL dan MinIO lokal yang berjalan langsung di OS laptop Anda secara lancar tanpa hambatan port-routing.

### Persyaratan
- Docker Engine & Docker Compose v2+ (Sistem Operasi Linux direkomendasikan untuk mode jaringan `host`).

### Cara Menjalankan

1. **Pastikan berkas `.env` sudah dikonfigurasi** (khususnya kredensial database lokal, MinIO lokal, serta Google OAuth Credentials).
2. **Jalankan container menggunakan Docker Compose:**
   ```bash
   docker compose up --build
   ```
   Perintah ini akan secara otomatis:
   - Membangun *production release* dari aplikasi Phoenix.
   - Menjalankan migrasi database Ecto secara otomatis sebelum aplikasi aktif.

4. **Akses Layanan:**
   - **Aplikasi Web**: [http://localhost:4000](http://localhost:4000)

### Perintah Docker Compose Penting

* **Menghentikan container:**
  ```bash
  docker compose down
  ```
* **Melihat log aplikasi:**
  ```bash
  docker compose logs -f web
  ```
  ```

---
*Dokumentasi bawaan Phoenix Framework:*
* [Official website](https://www.phoenixframework.org/)
* [Guides](https://hexdocs.pm/phoenix/overview.html)
* [Docs](https://hexdocs.pm/phoenix)
* [Forum](https://elixirforum.com/c/phoenix-forum)
* [Source](https://github.com/phoenixframework/phoenix)

