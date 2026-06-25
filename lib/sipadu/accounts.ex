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
      %User{} = user ->
        # Update image and name to keep it synced with Google
        update_attrs = %{
          "name" => attrs[:name] || attrs["name"],
          "image" => attrs[:image] || attrs["image"]
        }

        # We only update if the fields are actually present to avoid nulling them out
        update_attrs = Enum.reject(update_attrs, fn {_, v} -> is_nil(v) end) |> Enum.into(%{})

        {:ok, updated_user} = update_user(user, update_attrs)
        updated_user

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

  @doc """
  Mengembalikan daftar semua user diurutkan berdasarkan nama.
  """
  def list_users do
    User
    |> order_by(asc: :name)
    |> Repo.all()
  end

  @doc """
  Memperbarui role dari seorang user.
  """
  def update_user_role(%User{} = user, role) do
    user
    |> User.admin_changeset(%{role: role})
    |> Repo.update()
  end

  @doc """
  Memeriksa apakah user memiliki role admin.
  """
  def admin?(%User{role: "admin"}), do: true
  def admin?(_), do: false

  @doc """
  Menghitung jumlah total user di sistem.
  """
  def count_users do
    Repo.aggregate(User, :count)
  end
end
