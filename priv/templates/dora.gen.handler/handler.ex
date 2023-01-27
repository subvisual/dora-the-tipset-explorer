defmodule Dora.<%= @module_prefix %>.<%= @module_name %> do
  require Logger

  alias Dora.Repo
  alias Dora.Schema.{Event, EventProjection}
  alias Dora.Handlers.Utils

  def apply(address, %{"topics" => args}) do
    <%= if is_nil(@abi) do %><%= @event_type %> = %{}
    <% else %><%= @event_type %> = %{
      <%= for event <- @abi[@module_name] || [] do %><%= event.name %>: <%= inspect event.type %>,
      <% end %>
    }
    <% end %>
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
