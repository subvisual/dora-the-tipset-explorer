import Config

config :dora,
  ecto_repos: [Dora.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :dora, DoraWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: DoraWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Dora.PubSub,
  live_view: [signing_salt: "hbE8k63Z"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
