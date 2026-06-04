defmodule Sipadu.Pengaduan do
  @moduledoc """
  Context module for managing issue reports (Laporan).
  """

  import Ecto.Query, warn: false
  alias Sipadu.Repo
  alias Sipadu.Pengaduan.Laporan

  @doc """
  Returns the list of all laporan.
  """
  def list_laporan do
    Laporan
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of laporan filtered by user_id.
  """
  def list_laporan_by_user(user_id) do
    Laporan
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single laporan.
  """
  def get_laporan!(id), do: Repo.get!(Laporan, id)

  @doc """
  Creates a laporan.
  """
  def create_laporan(attrs \\ %{}) do
    %Laporan{}
    |> Laporan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a laporan.
  """
  def update_laporan(%Laporan{} = laporan, attrs) do
    laporan
    |> Laporan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking laporan changes.
  """
  def change_laporan(%Laporan{} = laporan, attrs \\ %{}) do
    Laporan.changeset(laporan, attrs)
  end
end
