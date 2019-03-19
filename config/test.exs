use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tertia, TertiaWeb.Endpoint,
  http: [port: 4002],
  server: false

config :tertia, :sandbox, absinthe_subscription: TertiaWeb.MainSenderSandbox
# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :tertia, Tertia.Repo,
  username: "postgres",
  password: "postgres",
  database: "tertia_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
