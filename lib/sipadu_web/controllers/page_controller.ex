defmodule SipaduWeb.PageController do
  use SipaduWeb, :controller

  defp get_default_faq() do
    [
      %{
        id: "d1",
        kategori: "Jaringan & Internet",
        q: "Wi-Fi kampus sering putus, apa yang harus saya lakukan?",
        a: "Pastikan Anda berada di area dengan jangkauan sinyal yang baik atau coba lupakan jaringan (forget network) dan login kembali."
      },
      %{
        id: "d2",
        kategori: "Perangkat Keras",
        q: "Printer atau komputer lab tidak berfungsi, bagaimana melapor?",
        a: "Silakan buat laporan dengan memilih kategori 'Perangkat Keras'. Pastikan Anda menyebutkan lokasi alat (Nama Gedung & No Ruangan) agar teknisi mudah mencarinya."
      },
      %{
        id: "d3",
        kategori: "Perangkat Lunak",
        q: "Bagaimana cara instalasi software berlisensi dari kampus?",
        a: "Buat tiket laporan pada kategori ini dengan menyebutkan nama software yang dibutuhkan. Tim kami akan merespon dengan tautan instalasi atau panduan."
      },
      %{
        id: "d4",
        kategori: "Akun & Email",
        q: "Lupa password email kampus atau portal?",
        a: "Jika fitur 'Lupa Password' gagal, ajukan laporan di kategori 'Akun & Email' dengan menyertakan foto KTM untuk proses verifikasi reset password."
      },
      %{
        id: "d5",
        kategori: "Website & Sistem Informas",
        q: "KRS Online tidak bisa diakses atau website error?",
        a: "Bisa jadi server sedang dalam masa maintenance. Jika error terus berlanjut, mohon lampirkan screenshot pesan error dan URL halaman yang bermasalah."
      },
      %{
        id: "d6",
        kategori: "Lainnya",
        q: "Kendala saya tidak termasuk dalam kategori di atas?",
        a: "Silakan pilih kategori 'Lainnya' dan jelaskan selengkap mungkin kronologi masalah Anda. Tim teknis akan menganalisis dan mengarahkannya ke divisi yang tepat."
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

  def cari(conn, %{"q" => query}) do
    db_faq = Sipadu.Pengaduan.search_resolved_laporan(query)
    mapped_db = Enum.map(db_faq, fn l -> 
      %{judul_laporan: l.judul_laporan, tanggapan_admin: l.tanggapan_admin}
    end)

    search_term = String.downcase(query)
    mapped_default = 
      get_default_faq()
      |> Enum.filter(fn d -> 
        String.contains?(String.downcase(d.q), search_term) or String.contains?(String.downcase(d.a), search_term)
      end)
      |> Enum.map(fn d -> %{judul_laporan: d.q, tanggapan_admin: d.a} end)

    faq = 
      (mapped_db ++ mapped_default)
      |> Enum.uniq_by(& &1.judul_laporan)

    render(conn, :cari, query: query, faq: faq)
  end
end
