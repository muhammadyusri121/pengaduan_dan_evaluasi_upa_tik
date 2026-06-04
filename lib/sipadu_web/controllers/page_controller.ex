defmodule SipaduWeb.PageController do
  use SipaduWeb, :controller

  def home(conn, _params) do
    kategori = [
      %{
        id: 1,
        nama: "Jaringan & Wi-Fi",
        icon: "hero-wifi",
        desc: "Masalah koneksi internet, Wi-Fi putus, akses jaringan"
      },
      %{
        id: 2,
        nama: "Sistem Akademik",
        icon: "hero-academic-cap",
        desc: "Portal akademik, registrasi online, nilai, KRS"
      },
      %{
        id: 3,
        nama: "Email Kampus",
        icon: "hero-envelope",
        desc: "Akses email, reset password, konfigurasi email"
      },
      %{
        id: 4,
        nama: "Perangkat Keras",
        icon: "hero-computer-desktop",
        desc: "Komputer lab, printer, proyektor, perangkat IT"
      },
      %{
        id: 5,
        nama: "Software & Lisensi",
        icon: "hero-cube",
        desc: "Instalasi software, aktivasi lisensi, update aplikasi"
      },
      %{
        id: 6,
        nama: "Website Kampus",
        icon: "hero-globe-alt",
        desc: "Akses website, error halaman, konten tidak muncul"
      }
    ]

    faq = [
      %{
        id: 1,
        q: "Wi-Fi kampus sering putus, apa yang harus saya lakukan?",
        a:
          "Pastikan Anda berada di area dengan jangkauan sinyal yang baik atau coba lupakan jaringan (forget network) dan login kembali."
      },
      %{
        id: 2,
        q: "Bagaimana cara mendapatkan akses Wi-Fi kampus?",
        a:
          "Gunakan NIM/NIP sebagai username dan password dari portal akademik Anda untuk login ke jaringan kampus."
      },
      %{
        id: 3,
        q: "Tidak bisa login ke portal akademik, apa solusinya?",
        a:
          "Silakan gunakan fitur 'Lupa Password' di halaman login portal, atau ajukan tiket bantuan pada kategori Sistem Akademik."
      },
      %{
        id: 4,
        q: "Cara mengaktifkan email kampus untuk mahasiswa baru?",
        a:
          "Mahasiswa baru dapat mengaktifkan email melalui portal akademik dengan memilih menu 'Aktivasi Layanan Google Workspace'."
      },
      %{
        id: 5,
        q: "Printer di lab tidak berfungsi, bagaimana cara melapor?",
        a:
          "Silakan buat laporan baru melalui sistem ini dengan memilih kategori 'Perangkat Keras' dan sebutkan lokasi lab dengan spesifik."
      }
    ]

    render(conn, :home, kategori: kategori, faq: faq)
  end
end
