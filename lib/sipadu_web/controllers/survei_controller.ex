defmodule SipaduWeb.SurveiController do
  @moduledoc """
  Controller untuk menangani rute terkait formulir survei Evaluasi Layanan UPA TIK.
  """
  use SipaduWeb, :controller

  alias Sipadu.Surveys
  alias Sipadu.Surveys.EvaluasiLayanan

  @doc """
  Merender halaman form survei.
  Menginisiasi changeset untuk digunakan di dalam form beserta data bawaan dari user.
  """
  def index(conn, _params) do
    # 1. Ambil data user yang sedang login dari assigns
    user = conn.assigns[:current_user]

    # 2. Buat map default_attrs jika user ada, jika tidak biarkan kosong
    default_attrs =
      if user do
        %{
          nama: user.name,
          nim_nip: user.nim_nip
          # Tambahkan field lain di sini jika skema EvaluasiLayanan membutuhkannya
          # misalnya: fakultas_unit_kerja: user.fakultas_unit_kerja
        }
      else
        %{}
      end

    # 3. Masukkan default_attrs ke dalam fungsi change_evaluasi_layanan
    changeset = Surveys.change_evaluasi_layanan(%EvaluasiLayanan{}, default_attrs)

    render(conn, :index,
      page_title: "Evaluasi Survei",
      form: Phoenix.Component.to_form(changeset)
    )
  end

  @doc """
  Memproses data survei yang dikirimkan melalui form.
  Menyimpan data ke database dan menampilkan pesan sukses atau error.
  """
  def create(conn, %{"evaluasi_layanan" => survei_params}) do
    # Mengambil user_id secara aman
    user_id = if conn.assigns[:current_user], do: conn.assigns.current_user.id, else: nil
    survei_params = Map.put(survei_params, "user_id", user_id)

    case Surveys.create_evaluasi_layanan(survei_params) do
      {:ok, _evaluasi} ->
        conn
        |> put_flash(:info, "Survei berhasil dikirim! Terima kasih atas partisipasinya.")
        |> redirect(to: ~p"/survei")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :index,
          page_title: "Evaluasi Survei",
          form: Phoenix.Component.to_form(changeset)
        )
    end
  end
end
