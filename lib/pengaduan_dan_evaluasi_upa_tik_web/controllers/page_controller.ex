defmodule PengaduanDanEvaluasiUpaTikWeb.PageController do
  use PengaduanDanEvaluasiUpaTikWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
