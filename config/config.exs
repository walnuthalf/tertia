# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tertia,
  ecto_repos: [Tertia.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :tertia, TertiaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "g5re2Aq4yhemTcOvpsoy1IDDRvkFDgw8VGdhNW8Mrnfid2uszDScI3cpNF9Ewk+N",
  render_errors: [view: TertiaWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Tertia.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :tertia, Tertia.Repo,
  extensions: [{Geo.PostGIS.Extension, library: Geo}],
  types: Tertia.PostgresTypes

# can't use Mix.env() in the code when deployed
config :tertia, env: Mix.env()
