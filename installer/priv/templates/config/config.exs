import Config

config :dora, Dora.Repo,
  database: "test_dora",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :dora, ecto_repos: [Dora.Repo]

config :tesla,
  adapter:
    {Tesla.Adapter.Hackney,
     [
       recv_timeout: 30_000,
       ssl_options: [verify: :verify_none]
     ]}
