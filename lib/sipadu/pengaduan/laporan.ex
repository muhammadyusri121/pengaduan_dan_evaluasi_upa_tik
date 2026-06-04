defmodule Sipadu.Pengaduan.Laporan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "laporan" do
    field :nama, :string
    field :nim_nip, :string
    field :no_hp, :string
    field :fakultas_unit_kerja, :string
    field :kategori, :string
    field :judul_laporan, :string
    field :deskripsi, :string
    field :lokasi, :string
    field :lampiran, :string
    field :status, :string, default: "Menunggu"
    field :tanggapan_admin, :string

    belongs_to :user, Sipadu.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(laporan, attrs) do
    laporan
    |> cast(attrs, [
      :nama,
      :nim_nip,
      :no_hp,
      :fakultas_unit_kerja,
      :kategori,
      :judul_laporan,
      :deskripsi,
      :lokasi,
      :lampiran,
      :status,
      :tanggapan_admin,
      :user_id
    ])
    |> validate_required([
      :nama,
      :nim_nip,
      :fakultas_unit_kerja,
      :kategori,
      :judul_laporan,
      :deskripsi,
      :lokasi
    ])
    |> validate_inclusion(:status, ["Menunggu", "Diproses", "Selesai", "Ditolak"])
  end
end
