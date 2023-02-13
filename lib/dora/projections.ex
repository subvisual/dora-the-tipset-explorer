defmodule Dora.Projections do
  alias Dora.Projections.EventProjection
  alias Dora.Repo

  import Ecto.Query

  def get_all_by_type(type, filters) do
    id = filters["id"]
    address = filters["contract_address"]

    projection_fields_filters =
      Map.drop(filters, ["contract_address", "id", "type"])
      |> Map.to_list()

    EventProjection
    |> where(projection_type: ^type)
    |> custom_filter(projection_id: id)
    |> custom_filter(address: address)
    |> custom_filter(projection_fields_filters)
    |> Repo.all()
  end

  def list_event_projections do
    Repo.all(EventProjection)
  end

  def get_event_projection!(id), do: Repo.get!(EventProjection, id)

  def create_event_projection(attrs \\ %{}) do
    %EventProjection{}
    |> EventProjection.changeset(attrs)
    |> Repo.insert()
  end

  def update_event_projection(%EventProjection{} = event_projection, attrs) do
    event_projection
    |> EventProjection.changeset(attrs)
    |> Repo.update()
  end

  def insert_or_update_event_projection(filters, new_params) do
    case Repo.get_by(EventProjection, filters) do
      nil -> %EventProjection{}
      projection -> projection
    end
    |> EventProjection.changeset(new_params)
    |> Repo.insert_or_update()
  end

  def delete_event_projection(%EventProjection{} = event_projection) do
    Repo.delete(event_projection)
  end

  def change_event_projection(%EventProjection{} = event_projection, attrs \\ %{}) do
    EventProjection.changeset(event_projection, attrs)
  end

  defp custom_filter(query, address: address) when not is_nil(address) do
    where(query, contract_address: ^address)
  end

  defp custom_filter(query, projection_id: id) when not is_nil(id) do
    where(query, projection_id: ^id)
  end

  defp custom_filter(query, [{key, value} | rest]) when not is_nil(value) do
    where(query, [event], event.event_args[^key] == ^value)
    |> custom_filter(rest)
  end

  defp custom_filter(query, _), do: query
end
