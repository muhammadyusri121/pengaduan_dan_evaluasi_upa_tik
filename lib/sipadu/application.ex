defmodule Sipadu.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SipaduWeb.Telemetry,
      Sipadu.Repo,
      {DNSCluster, query: Application.get_env(:sipadu, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Sipadu.PubSub},
      # Start a worker by calling: Sipadu.Worker.start_link(arg)
      # {Sipadu.Worker, arg},
      # Start to serve requests, typically the last entry
      SipaduWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sipadu.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SipaduWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
