defmodule Dora.Projections do
  alias Dora.Projections.EventProjection
  alias Dora.Repo

  import Ecto.Query

  def get_all_by_type(type, filters) do
    EventProjection
    |> where(projection_type: ^type)
    |> custom_filter(projection_id: filters["id"])
    |> custom_filter(address: filters["contract_address"])
    |> custom_filter(owner: filters["owner"])
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

  defp custom_filter(query, owner: owner) when not is_nil(owner) do
    where(query, [projection], projection.projection_fields["owner"] == ^owner)
  end

  defp custom_filter(query, _), do: query
end
