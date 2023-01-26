defmodule Dora.EventProjections do
  alias Dora.Schema.EventProjection
  alias Dora.Repo

  import Ecto.Query

  def get_all_by_type(type, filters) do
    EventProjection
    |> where(projection_type: ^type)
    |> custom_filter(projection_id: filters["id"])
    |> custom_filter(address: filters["contract_address"])
    |> custom_filter(owner: filters["from"])
    |> Repo.all()
  end

  defp custom_filter(query, address: address) when not is_nil(address) do
    where(query, contract_address: ^address)
  end

  defp custom_filter(query, projection_id: id) when not is_nil(id) do
    where(query, projection_id: ^id)
  end

  defp custom_filter(query, owner: owner) when not is_nil(owner) do
    where(query, [event], event.event_args["owner"] == ^owner)
  end

  defp custom_filter(query, _), do: query
end
