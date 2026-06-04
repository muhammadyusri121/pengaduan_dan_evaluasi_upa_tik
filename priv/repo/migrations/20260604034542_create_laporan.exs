defmodule Sipadu.Repo.Migrations.CreateLaporan do
  use Ecto.Migration

  def change do
    create table(:laporan) do
      add :nama, :string, null: false
      add :nim_nip, :string, null: false
      add :no_hp, :string
      add :fakultas_unit_kerja, :string, null: false
      add :kategori, :string, null: false
      add :judul_laporan, :string, null: false
      add :deskripsi, :text, null: false
      add :lokasi, :string, null: false
      add :lampiran, :string
      add :status, :string, null: false, default: "Menunggu"
      add :tanggapan_admin, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:laporan, [:user_id])
  end
end
