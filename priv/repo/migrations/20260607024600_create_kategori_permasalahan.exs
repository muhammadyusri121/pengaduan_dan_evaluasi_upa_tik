defmodule Sipadu.Repo.Migrations.CreateKategoriPermasalahan do
  use Ecto.Migration

  def change do
    create table(:kategori_permasalahan) do
      add :nama, :string, null: false
      add :deskripsi, :string
      add :aktif, :boolean, null: false, default: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:kategori_permasalahan, [:nama])
  end
end
