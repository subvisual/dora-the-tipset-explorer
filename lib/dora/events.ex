defmodule Dora.Events do
  alias Dora.Repo
  alias Dora.Events.Event

  import Ecto.Query

  def get_all_by_type(type, filters) do
    Event
    |> where(event_type: ^type)
    |> custom_filter(address: filters["contract_address"])
    |> custom_filter(from: filters["from"])
    |> custom_filter(to: filters["to"])
    |> custom_filter(id: filters["id"])
    |> Repo.all()
  end

  def list_events do
    Repo.all(Event)
  end

  def get_event!(id), do: Repo.get!(Event, id)

  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  defp custom_filter(query, address: address) when not is_nil(address) do
    where(query, contract_address: ^address)
  end

  defp custom_filter(query, from: from) when not is_nil(from) do
    where(query, [event], event.event_args["from"] == ^from)
  end

  defp custom_filter(query, to: to) when not is_nil(to) do
    where(query, [event], event.event_args["to"] == ^to)
  end

  defp custom_filter(query, id: id) when not is_nil(id) do
    where(query, [event], event.event_args["id"] == ^id)
  end

  defp custom_filter(query, _), do: query
end
