defmodule DoraWeb.EventJSON do
  alias Dora.Events.Event

  @doc """
  Renders a list of events.
  """
  def index(%{events: events}) do
    %{data: for(event <- events, do: data(event))}
  end

  @doc """
  Renders a single event.
  """
  def show(%{event: event}) do
    %{data: data(event)}
  end

  defp data(%Event{} = event) do
    %{
      id: event.id,
      contract_address: event.contract_address,
      event_type: event.event_type,
      event_args: event.event_args,
      inserted_at: event.inserted_at
    }
  end
end
