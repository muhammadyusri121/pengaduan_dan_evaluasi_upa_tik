defmodule SipaduWeb.PageController do
  use SipaduWeb, :controller

  def home(conn, _params) do
    render(conn, :home, page_title: "Selamat Datang")
  end
end
