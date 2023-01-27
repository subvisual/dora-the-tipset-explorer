import Config

config :dora, Dora.Repo,
  database: "dora",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :dora, ecto_repos: [Dora.Repo]
