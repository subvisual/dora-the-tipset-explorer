defmodule Dora.Repo do
  use Ecto.Repo,
    otp_app: :dora,
    adapter: Ecto.Adapters.Postgres
end
