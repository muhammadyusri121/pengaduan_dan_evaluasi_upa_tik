defmodule Sipadu.Pengaduan.KategoriPermasalahan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "kategori_permasalahan" do
    field :nama, :string
    field :deskripsi, :string
    field :aktif, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset untuk membuat atau memperbarui kategori permasalahan.
  """
  def changeset(kategori, attrs) do
    kategori
    |> cast(attrs, [:nama, :deskripsi, :aktif])
    |> validate_required([:nama])
    |> unique_constraint(:nama)
  end
end
