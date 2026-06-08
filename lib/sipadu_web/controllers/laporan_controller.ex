defmodule SipaduWeb.LaporanController do
  @moduledoc """
  Kontroler untuk menangani fitur Laporan Pengaduan, termasuk pengiriman form dan proxy file dari MinIO.
  """
  use SipaduWeb, :controller

  alias Sipadu.Pengaduan
  alias Sipadu.Pengaduan.Laporan
  alias Sipadu.MinioClient

  @doc """
  Merender daftar laporan pengaduan yang dikirimkan oleh pengguna yang sedang login.
  """
  def index(conn, _params) do
    user = conn.assigns.current_user
    laporan_list = Pengaduan.list_laporan_by_user(user.id)
    render(conn, :index, page_title: "Riwayat Laporan Pengaduan", laporan_list: laporan_list)
  end

  @doc """
  Merender formulir untuk membuat pengaduan baru.
  Mengisi otomatis bidang data diri berdasarkan sesi pengguna yang sedang login.
  """
  def new(conn, _params) do
    user = conn.assigns.current_user

    # Isi bidang formulir secara default dari profil pengguna jika tersedia
    default_attrs = %{
      nama: user.name,
      nim_nip: user.nim_nip,
      no_hp: user.no_hp,
      fakultas_unit_kerja: user.fakultas_unit_kerja
    }

    changeset = Pengaduan.change_laporan(%Laporan{}, default_attrs)
    kategori_list = Pengaduan.list_kategori_aktif()
    render(conn, :new, page_title: "Buat Laporan Pengaduan", form: Phoenix.Component.to_form(changeset), kategori_list: kategori_list)
  end

  @doc """
  Menangani pengiriman laporan pengaduan baru, termasuk proses upload file ke MinIO.
  """
  def create(conn, %{"laporan" => laporan_params}) do
    user = conn.assigns.current_user
    laporan_params = Map.put(laporan_params, "user_id", user.id)

    upload_result =
      case Map.get(laporan_params, "lampiran_file") do
        %Plug.Upload{} = upload ->
          # Sanitasi nama file dengan mengganti karakter non-alphanumeric menjadi underscore
          raw_filename = upload.filename
          ext = Path.extname(raw_filename)
          
          sanitized_base = 
            raw_filename
            |> Path.rootname()
            |> String.replace(~r/[^a-zA-Z0-9_\-]/, "_")
            
          unique_filename = "#{System.system_time(:millisecond)}_#{sanitized_base}#{ext}"
          file_binary = File.read!(upload.path)

          case MinioClient.upload_file(unique_filename, file_binary, upload.content_type) do
            {:ok, _stored_name} ->
              {:ok, Map.put(laporan_params, "lampiran", unique_filename)}

            {:error, reason} ->
              {:error, reason}
          end

        _ ->
          {:ok, laporan_params}
      end

    case upload_result do
      {:ok, final_params} ->
        case Pengaduan.create_laporan(final_params) do
          {:ok, _laporan} ->
            conn
            |> put_flash(:info, "Laporan pengaduan berhasil dikirim! Silakan pantau status penanganan di halaman ini.")
            |> redirect(to: ~p"/laporan")

          {:error, %Ecto.Changeset{} = changeset} ->
            kategori_list = Pengaduan.list_kategori_aktif()
            render(conn, :new, page_title: "Buat Laporan Pengaduan", form: Phoenix.Component.to_form(changeset), kategori_list: kategori_list)
        end

      {:error, reason} ->
        changeset =
          %Laporan{}
          |> Pengaduan.change_laporan(laporan_params)
          |> Ecto.Changeset.add_error(:lampiran, "gagal diunggah ke penyimpanan (MinIO): #{inspect(reason)}")

        kategori_list = Pengaduan.list_kategori_aktif()
        conn
        |> put_flash(:error, "Gagal mengunggah file.")
        |> render(:new, page_title: "Buat Laporan Pengaduan", form: Phoenix.Component.to_form(changeset), kategori_list: kategori_list)
    end
  end

  @doc """
  Endpoint proxy untuk menyajikan file yang telah diunggah ke MinIO.
  Menyembunyikan URL, IP, dan port MinIO dari client.
  """
  def show_file(conn, %{"filename" => filename}) do
    case MinioClient.get_file(filename) do
      {:ok, file_binary, content_type} ->
        conn
        |> put_resp_header("content-disposition", "inline; filename=\"#{filename}\"")
        |> put_resp_content_type(content_type)
        |> send_resp(200, file_binary)

      {:error, _reason} ->
        conn
        |> put_status(:not_found)
        |> put_view(SipaduWeb.ErrorHTML)
        |> render(:"404")
    end
  end
end
