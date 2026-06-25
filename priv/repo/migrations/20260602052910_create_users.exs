defmodule Sipadu.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :name, :string
      add :image, :string

      # Additional Profile Fields
      add :jabatan, :string
      add :nim_nip, :string
      add :no_hp, :string
      add :fakultas_unit_kerja, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
