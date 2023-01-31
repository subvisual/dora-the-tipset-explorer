defmodule Dora.New.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :dora_new,
      version: @version,
      elixir: "~> 1.14.3",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger, :eex]]
  end

  defp deps do
    []
  end
end
