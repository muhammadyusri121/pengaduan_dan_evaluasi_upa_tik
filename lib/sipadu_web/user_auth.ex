defmodule SipaduWeb.UserAuth do
  @moduledoc """
  Modul ini mengatur alur autentikasi dan otorisasi pengguna di dalam Phoenix.

  Termasuk Plugs untuk memeriksa session, memuat data User dari database,
  serta hooks (on_mount) yang dipakai oleh LiveView untuk proteksi halaman.
  """
  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Mencari user ID dari session saat ini dan mengambil data User dari database.
  Data tersebut kemudian disimpan (assign) ke dalam `conn` agar bisa
  diakses dari View maupun Controller lewat `@current_user`.
  """
  def fetch_current_user(conn, _opts) do
    case get_session(conn, :current_user) do
      id when is_integer(id) ->
        user = Sipadu.Accounts.get_user(id)
        assign(conn, :current_user, user)

      _ ->
        # Clear legacy sessions that store a map
        assign(conn, :current_user, nil)
    end
  end

  @doc """
  Sebuah Plug untuk memproteksi *route*. Jika `conn.assigns[:current_user]` kosong (belum login),
  pengguna akan diarahkan (redirect) ke halaman `/login`.
  """
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

  @doc """
  Sebuah Plug untuk memproteksi *route* admin. Jika `conn.assigns[:current_user]` tidak
  memiliki role admin, pengguna akan diarahkan ke halaman utama.
  """
  def require_admin(conn, _opts) do
    if conn.assigns[:current_user] && conn.assigns[:current_user].role == "admin" do
      conn
    else
      conn
      |> put_flash(:error, "Anda tidak memiliki akses ke halaman ini.")
      |> redirect(to: "/")
      |> halt()
    end
  end

  @doc """
  Hook siklus hidup LiveView untuk memproteksi *route* LiveView (mirip dengan require_authenticated_user).
  """
  def on_mount(:ensure_authenticated, _params, session, socket) do
    case session["current_user"] do
      id when is_integer(id) ->
        user = Sipadu.Accounts.get_user(id)
        {:cont, Phoenix.Component.assign(socket, :current_user, user)}

      _ ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/login")}
    end
  end

  def on_mount(:ensure_admin, _params, session, socket) do
    case session["current_user"] do
      id when is_integer(id) ->
        user = Sipadu.Accounts.get_user(id)

        if user && user.role == "admin" do
          {:cont, Phoenix.Component.assign(socket, :current_user, user)}
        else
          {:halt, Phoenix.LiveView.redirect(socket, to: "/")}
        end

      _ ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/login")}
    end
  end

  def on_mount(:mount_current_user, _params, session, socket) do
    user =
      case session["current_user"] do
        id when is_integer(id) -> Sipadu.Accounts.get_user(id)
        _ -> nil
      end

    {:cont, Phoenix.Component.assign(socket, :current_user, user)}
  end
end
