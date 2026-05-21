defmodule SipaduWeb.AuthController do
  use SipaduWeb, :controller
  plug Ueberauth

  def login(conn, _params) do
    render(conn, :login)
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    allowed_domains = ["@student.trunojoyo.ac.id", "@trunojoyo.ac.id"]
    email = auth.info.email

    if Enum.any?(allowed_domains, fn domain -> String.ends_with?(email, domain) end) do
      user_info = %{
        name: auth.info.name,
        email: email,
        image: auth.info.image
      }

      conn
      |> put_session(:current_user, user_info)
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
