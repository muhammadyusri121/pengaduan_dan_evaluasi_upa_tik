defmodule Sipadu.Accounts.User do
  @moduledoc """
  Schema Ecto untuk memetakan data pengguna (User) ke tabel `users` di database.
  
  Tabel ini menyimpan informasi dasar dari Google OAuth (`email`, `name`, `image`) 
  dan atribut profil tambahan (`jabatan`, `nim_nip`, `no_hp`, `fakultas_unit_kerja`).
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :image, :string
    
    # Profile fields
    field :jabatan, :string
    field :nim_nip, :string
    field :no_hp, :string
    field :fakultas_unit_kerja, :string

    timestamps(type: :utc_datetime)
  end

  @doc """
  Fungsi changeset untuk memvalidasi dan mentransformasi data mentah (attrs)
  sebelum dimasukkan atau diperbarui ke dalam database.
  
  Memastikan `email` bersifat wajib (required) dan unik.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :image, :jabatan, :nim_nip, :no_hp, :fakultas_unit_kerja])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
