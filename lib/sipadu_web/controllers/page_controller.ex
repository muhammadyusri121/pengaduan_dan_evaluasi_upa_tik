defmodule SipaduWeb.PageController do
  use SipaduWeb, :controller

  defp get_default_faq() do
    [
      %{
        id: "d1",
        kategori: "Jaringan & Wi-Fi",
        q: "Wi-Fi kampus sering putus, apa yang harus saya lakukan?",
        a: "Pastikan Anda berada di area dengan jangkauan sinyal yang baik atau coba lupakan jaringan (forget network) dan login kembali."
      },
      %{
        id: "d2",
        kategori: "Jaringan & Wi-Fi",
        q: "Bagaimana cara mendapatkan akses Wi-Fi kampus?",
        a: "Gunakan NIM/NIP sebagai username dan password dari portal akademik Anda untuk login ke jaringan kampus."
      },
      %{
        id: "d3",
        kategori: "Sistem Akademik",
        q: "Tidak bisa login ke portal akademik, apa solusinya?",
        a: "Silakan gunakan fitur 'Lupa Password' di halaman login portal, atau ajukan tiket bantuan pada kategori Sistem Akademik."
      },
      %{
        id: "d4",
        kategori: "Email Kampus",
        q: "Cara mengaktifkan email kampus untuk mahasiswa baru?",
        a: "Mahasiswa baru dapat mengaktifkan email melalui portal akademik dengan memilih menu 'Aktivasi Layanan Google Workspace'."
      },
      %{
        id: "d5",
        kategori: "Perangkat Keras",
        q: "Printer di lab tidak berfungsi, bagaimana cara melapor?",
        a: "Silakan buat laporan baru melalui sistem ini dengan memilih kategori 'Perangkat Keras' dan sebutkan lokasi lab dengan spesifik."
      }
    ]
  end

  def home(conn, _params) do
    kategori_db = Sipadu.Pengaduan.list_kategori_aktif()
    kategori = Enum.map(kategori_db, fn k -> 
      icon = cond do
        String.match?(String.downcase(k.nama), ~r/jaringan|wifi|internet/) -> "hero-wifi"
        String.match?(String.downcase(k.nama), ~r/sistem|akademik|portal/) -> "hero-academic-cap"
        String.match?(String.downcase(k.nama), ~r/email|surat/) -> "hero-envelope"
        String.match?(String.downcase(k.nama), ~r/perangkat|hardware|komputer|printer/) -> "hero-computer-desktop"
        String.match?(String.downcase(k.nama), ~r/software|aplikasi|lisensi/) -> "hero-cube"
        String.match?(String.downcase(k.nama), ~r/web/) -> "hero-globe-alt"
        true -> "hero-hashtag"
      end

      %{
        id: k.id,
        nama: k.nama,
        icon: icon,
        desc: k.deskripsi || "Pusat bantuan seputar #{k.nama}"
      }
    end)

    default_faq = get_default_faq()

    db_faq = Sipadu.Pengaduan.get_popular_faq(5)

    faq = 
      (db_faq ++ default_faq)
      |> Enum.uniq_by(& &1.q)
      |> Enum.take(5)

    render(conn, :home, kategori: kategori, faq: faq)
  end

  def topik(conn, %{"kategori" => kategori}) do
    db_faq = Sipadu.Pengaduan.list_resolved_laporan_by_kategori(kategori)
    mapped_db = Enum.map(db_faq, fn l -> 
      %{judul_laporan: l.judul_laporan, tanggapan_admin: l.tanggapan_admin}
    end)
    
    mapped_default = 
      get_default_faq()
      |> Enum.filter(& &1.kategori == kategori)
      |> Enum.map(fn d -> %{judul_laporan: d.q, tanggapan_admin: d.a} end)
      
    faq = 
      (mapped_db ++ mapped_default)
      |> Enum.uniq_by(& &1.judul_laporan)

    render(conn, :topik, kategori_nama: kategori, faq: faq)
  end
end
