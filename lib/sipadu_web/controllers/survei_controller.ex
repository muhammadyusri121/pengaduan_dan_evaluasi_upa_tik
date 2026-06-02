defmodule SipaduWeb.SurveiController do
  @moduledoc """
  Controller untuk menangani rute terkait formulir survei Evaluasi Layanan UPA TIK.
  """
  use SipaduWeb, :controller

  alias Sipadu.Surveys
  alias Sipadu.Surveys.EvaluasiLayanan

  @doc """
  Merender halaman form survei.
  Menginisiasi changeset kosong untuk digunakan di dalam form.
  """
  def index(conn, _params) do
    changeset = Surveys.change_evaluasi_layanan(%EvaluasiLayanan{})
    render(conn, :index, page_title: "Evaluasi Survei", form: Phoenix.Component.to_form(changeset))
  end
  
  @doc """
  Memproses data survei yang dikirimkan melalui form.
  Menyimpan data ke database dan menampilkan pesan sukses atau error.
  """
  def create(conn, %{"evaluasi_layanan" => survei_params}) do
    # Add user_id from conn.assigns.current_user if it exists
    user_id = if conn.assigns[:current_user], do: conn.assigns.current_user.id, else: nil
    survei_params = Map.put(survei_params, "user_id", user_id)

    case Surveys.create_evaluasi_layanan(survei_params) do
      {:ok, _evaluasi} ->
        conn
        |> put_flash(:info, "Survei berhasil dikirim! Terima kasih atas partisipasinya.")
        |> redirect(to: ~p"/survei")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :index, page_title: "Evaluasi Survei", form: Phoenix.Component.to_form(changeset))
    end
  end
end
