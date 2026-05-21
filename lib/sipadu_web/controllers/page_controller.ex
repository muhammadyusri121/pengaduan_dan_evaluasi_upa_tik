defmodule SipaduWeb.PageController do
  use SipaduWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
