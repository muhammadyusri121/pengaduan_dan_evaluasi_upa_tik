defmodule Sipadu.Surveys do
  @moduledoc """
  The Surveys context.
  """

  import Ecto.Query, warn: false
  alias Sipadu.Repo

  alias Sipadu.Surveys.EvaluasiLayanan

  @doc """
  Returns the list of evaluasi_layanan.

  ## Examples

      iex> list_evaluasi_layanan()
      [%EvaluasiLayanan{}, ...]

  """
  def list_evaluasi_layanan do
    Repo.all(EvaluasiLayanan)
  end

  @doc """
  Gets a single evaluasi_layanan.

  Raises `Ecto.NoResultsError` if the Evaluasi layanan does not exist.

  ## Examples

      iex> get_evaluasi_layanan!(123)
      %EvaluasiLayanan{}

      iex> get_evaluasi_layanan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_evaluasi_layanan!(id), do: Repo.get!(EvaluasiLayanan, id)

  @doc """
  Creates a evaluasi_layanan.

  ## Examples

      iex> create_evaluasi_layanan(%{field: value})
      {:ok, %EvaluasiLayanan{}}

      iex> create_evaluasi_layanan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_evaluasi_layanan(attrs \\ %{}) do
    %EvaluasiLayanan{}
    |> EvaluasiLayanan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking evaluasi_layanan changes.

  ## Examples

      iex> change_evaluasi_layanan(evaluasi_layanan)
      %Ecto.Changeset{data: %EvaluasiLayanan{}}

  """
  def change_evaluasi_layanan(%EvaluasiLayanan{} = evaluasi_layanan, attrs \\ %{}) do
    EvaluasiLayanan.changeset(evaluasi_layanan, attrs)
  end

  @doc """
  Menghitung jumlah total evaluasi layanan.
  """
  def count_evaluasi do
    Repo.aggregate(EvaluasiLayanan, :count)
  end

  @doc """
  Menghitung rata-rata rating dari setiap aspek evaluasi.
  """
  def average_ratings do
    Repo.one(
      from(e in EvaluasiLayanan,
        select: %{
          kemudahan_pengajuan: avg(e.kemudahan_pengajuan),
          kecepatan_respon: avg(e.kecepatan_respon),
          kecepatan_penanganan: avg(e.kecepatan_penanganan),
          kualitas_layanan: avg(e.kualitas_layanan)
        }
      )
    )
  end
end
