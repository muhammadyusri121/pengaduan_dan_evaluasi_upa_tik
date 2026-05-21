defmodule PengaduanDanEvaluasiUpaTik.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PengaduanDanEvaluasiUpaTikWeb.Telemetry,
      PengaduanDanEvaluasiUpaTik.Repo,
      {DNSCluster, query: Application.get_env(:pengaduan_dan_evaluasi_upa_tik, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PengaduanDanEvaluasiUpaTik.PubSub},
      # Start a worker by calling: PengaduanDanEvaluasiUpaTik.Worker.start_link(arg)
      # {PengaduanDanEvaluasiUpaTik.Worker, arg},
      # Start to serve requests, typically the last entry
      PengaduanDanEvaluasiUpaTikWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PengaduanDanEvaluasiUpaTik.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PengaduanDanEvaluasiUpaTikWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
