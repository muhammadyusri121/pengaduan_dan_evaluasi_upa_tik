defmodule Sipadu.Repo do
  use Ecto.Repo,
    otp_app: :sipadu,
    adapter: Ecto.Adapters.Postgres
end
