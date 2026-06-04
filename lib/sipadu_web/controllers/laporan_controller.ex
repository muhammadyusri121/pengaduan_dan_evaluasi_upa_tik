defmodule SipaduWeb.LaporanController do
  @moduledoc """
  Controller to handle Laporan (Reporting) features, including submission and file proxying from MinIO.
  """
  use SipaduWeb, :controller

  alias Sipadu.Pengaduan
  alias Sipadu.Pengaduan.Laporan
  alias Sipadu.MinioClient

  @doc """
  Renders the list of reports submitted by the logged-in user.
  """
  def index(conn, _params) do
    user = conn.assigns.current_user
    laporan_list = Pengaduan.list_laporan_by_user(user.id)
    render(conn, :index, page_title: "Riwayat Laporan Pengaduan", laporan_list: laporan_list)
  end

  @doc """
  Renders the form to create a new report.
  Pre-populates user data from the logged-in user session.
  """
  def new(conn, _params) do
    user = conn.assigns.current_user

    # Pre-populate fields from the current user profile if available
    default_attrs = %{
      nama: user.name,
      nim_nip: user.nim_nip,
      no_hp: user.no_hp,
      fakultas_unit_kerja: user.fakultas_unit_kerja
    }

    changeset = Pengaduan.change_laporan(%Laporan{}, default_attrs)
    render(conn, :new, page_title: "Buat Laporan Pengaduan", form: Phoenix.Component.to_form(changeset))
  end

  @doc """
  Handles the submission of a new report, including file upload to MinIO.
  """
  def create(conn, %{"laporan" => laporan_params}) do
    user = conn.assigns.current_user
    laporan_params = Map.put(laporan_params, "user_id", user.id)

    upload_result =
      case Map.get(laporan_params, "lampiran_file") do
        %Plug.Upload{} = upload ->
          # Sanitize filename by replacing non-alphanumeric chars with underscores
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
            render(conn, :new, page_title: "Buat Laporan Pengaduan", form: Phoenix.Component.to_form(changeset))
        end

      {:error, reason} ->
        changeset =
          %Laporan{}
          |> Pengaduan.change_laporan(laporan_params)
          |> Ecto.Changeset.add_error(:lampiran, "gagal diunggah ke penyimpanan (MinIO): #{inspect(reason)}")

        conn
        |> put_flash(:error, "Gagal mengunggah file.")
        |> render(:new, page_title: "Buat Laporan Pengaduan", form: Phoenix.Component.to_form(changeset))
    end
  end

  @doc """
  Proxy endpoint to serve files uploaded to MinIO.
  Hides the MinIO URL, IP, and port from the client.
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
