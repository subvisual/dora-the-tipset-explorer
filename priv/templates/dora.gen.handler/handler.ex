defmodule Dora.<%= @module_prefix %>.<%= @module_name %> do
  require Logger

  alias Dora.Repo
  alias Dora.Schema.{Event, EventProjection}
  alias Dora.Handlers.Utils

  def apply(address, %{"topics" => args}) do
    <%= @event_type %> = %{}

    Repo.transaction(fn ->
      %Event{}
      |> Event.changeset(%{
        event_type: "<%= @event_type %>",
        contract_address: address,
        event_args: <%= @event_type %>
      })
      |> Repo.insert()

      # Add projection code here
    end)
    |> case do
      {:ok, _} = result -> result
      error -> Logger.error("Failed to run transaction. Error: #{inspect(error)}")
    end
  end
end
