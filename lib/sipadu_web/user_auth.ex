defmodule SipaduWeb.UserAuth do
  import Plug.Conn
  import Phoenix.Controller

  def fetch_current_user(conn, _opts) do
    user = get_session(conn, :current_user)
    assign(conn, :current_user, user)
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Anda harus login untuk mengakses halaman ini.")
      |> redirect(to: "/login")
      |> halt()
    end
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    case session["current_user"] do
      nil ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/login")}
      user ->
        {:cont, Phoenix.Component.assign(socket, :current_user, user)}
    end
  end

  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, Phoenix.Component.assign(socket, :current_user, session["current_user"])}
  end
end
