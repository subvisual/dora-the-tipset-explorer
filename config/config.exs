import Config

config :dora,
  ecto_repos: [Dora.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :dora, DoraWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: DoraWeb.ErrorHTML, json: DoraWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Dora.PubSub,
  live_view: [signing_salt: "hbE8k63Z"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :dora, :explorer, refresh_rate: 10_000

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
