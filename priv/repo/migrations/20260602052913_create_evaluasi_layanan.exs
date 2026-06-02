defmodule Sipadu.Repo.Migrations.CreateEvaluasiLayanan do
  use Ecto.Migration

  def change do
    create table(:evaluasi_layanan) do
      add :nama, :string, null: false
      add :jabatan, :string, null: false
      add :nim_nip, :string, null: false
      add :no_hp, :string
      add :fakultas_unit_kerja, :string, null: false
      add :layanan_yang_diminta, :string, null: false
      add :masukan, :text
      add :kemudahan_pengajuan, :integer, null: false
      add :kecepatan_respon, :integer, null: false
      add :kecepatan_penanganan, :integer, null: false
      add :kualitas_layanan, :integer, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:evaluasi_layanan, [:user_id])
  end
end
