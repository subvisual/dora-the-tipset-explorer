defmodule Dora.Handlers.Defaults.Transfer do
  require Logger

  alias Dora.Repo
  alias Dora.Events
  alias Dora.Projections.EventProjection
  alias Dora.Handlers.Utils

  def apply(address, {_function, topics}) do
    topics_map = Utils.build_topics_maps(topics)

    new_owner = topics_map["to"]
    id = topics_map["tokenId"]

    transfer = %{
      from: topics_map["from"],
      to: new_owner,
      id: id
    }

    Repo.transaction(fn ->
      Events.create_event(%{
        event_type: "transfer",
        contract_address: address,
        event_args: transfer
      })

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
