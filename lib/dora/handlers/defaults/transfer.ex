defmodule Dora.Handlers.Defaults.Transfer do
  require Logger

  alias Dora.Repo
  alias Dora.Schema.{Event, EventProjection}
  alias Dora.Handlers.Utils

  # Ignore first element from the array because it
  # corresponds to the Event hash
  def apply(address, %{"topics" => [_event_hash | args]}) do
    new_owner = Utils.hex_to_eth_address(Enum.at(args, 1))

    id =
      args
      |> Enum.at(2)
      |> Utils.hex_to_integer_string()

    transfer = %{
      from: Utils.hex_to_eth_address(Enum.at(args, 0)),
      to: new_owner,
      id: id
    }

    Repo.transaction(fn ->
      %Event{}
      |> Event.changeset(%{
        event_type: "transfer",
        contract_address: address,
        event_args: transfer
      })
      |> Repo.insert()

      projection_changes = %{
        contract_address: address,
        projection_type: "nft",
        projection_id: id,
        projection_fields: %{owner: new_owner}
      }

      case Repo.get_by(EventProjection,
             contract_address: address,
             projection_type: "nft",
             projection_id: id
           ) do
        nil -> %EventProjection{}
        projection -> projection
      end
      |> EventProjection.changeset(projection_changes)
      |> Repo.insert_or_update()
    end)
    |> case do
      {:ok, _} = result -> result
      error -> Logger.error("Failed to run transaction. Error: #{inspect(error)}")
    end
  end
end
