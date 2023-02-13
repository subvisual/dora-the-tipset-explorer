defmodule Dora.Events do
  alias Dora.Repo
  alias Dora.Events.Event

  import Ecto.Query

  def get_all_by_type(type, filters) do
    address = filters["contract_address"]

    event_args_filters =
      Map.drop(filters, ["contract_address", "type"])
      |> Map.to_list()

    Event
    |> where(event_type: ^type)
    |> custom_filter(address: address)
    |> custom_filter(event_args_filters)
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

  defp custom_filter(query, [{key, value} | rest]) when not is_nil(value) do
    where(query, [event], event.event_args[^key] == ^value)
    |> custom_filter(rest)
  end

  defp custom_filter(query, _), do: query
end
