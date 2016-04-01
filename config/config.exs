# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :over_hosting, OverHosting.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "nyoEKNS+1NH34YV+S3zGNjIe1/1uV+HZeBSSYPR9CB3DlMQk499bx+KwlhWHIL+u",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: OverHosting.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :over_hosting, OverHosting.Servers,
  data_folder: "./server_data"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
