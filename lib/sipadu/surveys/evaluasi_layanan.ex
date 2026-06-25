defmodule Sipadu.Surveys.EvaluasiLayanan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "evaluasi_layanan" do
    field :nama, :string
    field :jabatan, :string
    field :nim_nip, :string
    field :no_hp, :string
    field :fakultas_unit_kerja, :string
    field :layanan_yang_diminta, :string
    field :masukan, :string
    field :kemudahan_pengajuan, :integer
    field :kecepatan_respon, :integer
    field :kecepatan_penanganan, :integer
    field :kualitas_layanan, :integer

    # Optional relation to user
    belongs_to :user, Sipadu.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(evaluasi_layanan, attrs) do
    evaluasi_layanan
    |> cast(attrs, [
      :nama,
      :jabatan,
      :nim_nip,
      :no_hp,
      :fakultas_unit_kerja,
      :layanan_yang_diminta,
      :masukan,
      :kemudahan_pengajuan,
      :kecepatan_respon,
      :kecepatan_penanganan,
      :kualitas_layanan,
      :user_id
    ])
    |> validate_required([
      :nama,
      :jabatan,
      :nim_nip,
      :fakultas_unit_kerja,
      :layanan_yang_diminta,
      :kemudahan_pengajuan,
      :kecepatan_respon,
      :kecepatan_penanganan,
      :kualitas_layanan
    ])
    |> validate_inclusion(:kemudahan_pengajuan, 1..5)
    |> validate_inclusion(:kecepatan_respon, 1..5)
    |> validate_inclusion(:kecepatan_penanganan, 1..5)
    |> validate_inclusion(:kualitas_layanan, 1..5)
  end
end
