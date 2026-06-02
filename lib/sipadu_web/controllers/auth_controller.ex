defmodule SipaduWeb.AuthController do
  @moduledoc """
  Controller yang menangani rute login dan callback dari Google OAuth (Ueberauth).
  """
  use SipaduWeb, :controller
  plug Ueberauth

  @doc """
  Merender halaman login manual (jika ada), atau sekadar tombol login via Google.
  """
  def login(conn, _params) do
    render(conn, :login)
  end

  @doc """
  Callback sukses dari Google OAuth. Memeriksa domain email (hanya @student.trunojoyo.ac.id 
  atau @trunojoyo.ac.id yang diizinkan). Jika valid, menyimpan (upsert) data user ke 
  database dan meletakkan `user.id` ke dalam session.
  """
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    allowed_domains = ["@student.trunojoyo.ac.id", "@trunojoyo.ac.id"]
    email = auth.info.email

    if Enum.any?(allowed_domains, fn domain -> String.ends_with?(email, domain) end) do
      user = Sipadu.Accounts.get_or_create_user_by_email(%{
        email: email,
        name: auth.info.name,
        image: auth.info.image
      })

      conn
      |> put_session(:current_user, user.id)
      |> put_flash(:info, "Berhasil masuk.")
      |> redirect(to: ~p"/")
    else
      conn
      |> put_flash(:error, "Akses ditolak. Harap gunakan email kampus (@student.trunojoyo.ac.id atau @trunojoyo.ac.id).")
      |> redirect(to: ~p"/login")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Gagal masuk menggunakan Google. Silakan coba lagi.")
    |> redirect(to: ~p"/login")
  end

  def signout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Signed out successfully.")
    |> redirect(to: ~p"/")
  end
end
