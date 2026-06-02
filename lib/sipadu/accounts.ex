defmodule Sipadu.Accounts do
  @moduledoc """
  The Accounts context.
  
  Mendefinisikan fungsi-fungsi untuk mengelola data user,
  termasuk mengambil, membuat, dan memperbarui profil pengguna 
  yang terhubung melalui Google OAuth.
  """
  import Ecto.Query, warn: false
  alias Sipadu.Repo
  alias Sipadu.Accounts.User

  @doc """
  Mengambil data user berdasarkan ID database.
  Mengembalikan `%User{}` atau `nil` jika tidak ditemukan.
  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Mengambil data user berdasarkan alamat email.
  Mengembalikan `%User{}` atau `nil` jika tidak ditemukan.
  """
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  @doc """
  Mencari user berdasarkan email. Jika belum ada, 
  maka akan membuat record user baru secara otomatis (digunakan saat OAuth login).
  """
  def get_or_create_user_by_email(attrs) do
    email = attrs[:email] || attrs["email"]

    case get_user_by_email(email) do
      %User{} = user -> user
      nil ->
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert!()
    end
  end

  @doc """
  Membuat Ecto.Changeset untuk melacak perubahan pada data user.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Memperbarui data profil user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end
end
