defmodule DoraWeb.EventView do
  use DoraWeb, :view
  alias DoraWeb.EventView

  def render("index.json", %{events: events}) do
    %{data: render_many(events, EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    %{
      id: event.id,
      contract_address: event.contract_address,
      event_type: event.event_type,
      event_args: event.event_args,
      inserted_at: event.inserted_at
    }
  end
end
