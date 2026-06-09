alias Sipadu.Repo
alias Sipadu.Accounts
alias Sipadu.Pengaduan

IO.puts("=== SEEDING KATEGORI PERMASALAHAN DEFAULT ===")

kategori_defaults = [
  %{nama: "Jaringan & Internet", deskripsi: "Masalah koneksi WiFi, LAN, atau internet kampus"},
  %{nama: "Perangkat Keras", deskripsi: "Kerusakan komputer, printer, proyektor, dll"},
  %{nama: "Perangkat Lunak", deskripsi: "Error aplikasi, instalasi software, lisensi"},
  %{nama: "Akun & Email", deskripsi: "Masalah login email kampus, reset password"},
  %{nama: "Website & Sistem Informasi", deskripsi: "Bug atau error pada website kampus"},
  %{nama: "Lainnya", deskripsi: "Permasalahan TIK lainnya yang tidak tercakup"}
]

for attrs <- kategori_defaults do
  case Repo.get_by(Sipadu.Pengaduan.KategoriPermasalahan, nama: attrs.nama) do
    nil ->
      case Pengaduan.create_kategori(attrs) do
        {:ok, kat} ->
          IO.puts("  ✅ Kategori: #{kat.nama} berhasil dibuat.")

        {:error, changeset} ->
          IO.puts("  ❌ Gagal membuat kategori #{attrs.nama}: #{inspect(changeset.errors)}")
      end

    _kat ->
      IO.puts("  ⏭️  Kategori: #{attrs.nama} sudah ada di database.")
  end
end

IO.puts("\n=== SEEDING ADMIN USER ===")
admin_email = "230441100192@student.trunojoyo.ac.id"

case Accounts.get_user_by_email(admin_email) do
  nil ->
    IO.puts("  ⚠️  Pengguna dengan email #{admin_email} belum ada.")

    IO.puts(
      "      Silakan login sekali melalui Google OAuth, kemudian jalankan kembali `mix run priv/repo/seeds.exs` untuk mempromosikan akun Anda menjadi Admin."
    )

  user ->
    case Accounts.update_user_role(user, "admin") do
      {:ok, updated} ->
        IO.puts(
          "  ✅ Akun #{updated.name} (#{updated.email}) berhasil dipromosikan sebagai Admin!"
        )

      {:error, changeset} ->
        IO.puts("  ❌ Gagal mempromosikan akun admin: #{inspect(changeset.errors)}")
    end
end
