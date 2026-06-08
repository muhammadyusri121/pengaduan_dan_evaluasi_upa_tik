import Config

# Load .env if it exists to retrieve local database credentials
env_path = Path.expand("../.env", __DIR__)
if File.exists?(env_path) do
  for line <- File.stream!(env_path, [], :line),
      line = String.trim(line),
      line != "",
      not String.starts_with?(line, "#") do
    case String.split(line, "=", parts: 2) do
      [key, val] -> System.put_env(String.trim(key), String.trim(val))
      _ -> :ok
    end
  end
end

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :sipadu, Sipadu.Repo,
  username: System.get_env("POSTGRES_USER") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "passwd2972",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  database: "sipadu_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sipadu, SipaduWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "WkO1xIErYWMlNENWdNidVJktSwiLRL4+KUF0wvED4Isz2gL7YRXwV1UN/VFFgY1F",
  server: false

# In test we don't send emails
config :sipadu, Sipadu.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
