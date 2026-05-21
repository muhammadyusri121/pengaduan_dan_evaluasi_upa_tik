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

## Informasi Lingkungan (Environment)

- **Elixir / Phoenix**: Aplikasi dibangun menggunakan Phoenix v1.8+
- **Autentikasi**: Ueberauth Google OAuth
- **Database**: PostgreSQL (dikelola melalui Ecto)

---
*Dokumentasi bawaan Phoenix Framework:*
* [Official website](https://www.phoenixframework.org/)
* [Guides](https://hexdocs.pm/phoenix/overview.html)
* [Docs](https://hexdocs.pm/phoenix)
* [Forum](https://elixirforum.com/c/phoenix-forum)
* [Source](https://github.com/phoenixframework/phoenix)
