defmodule DoraWeb.EventController do
  use DoraWeb, :controller

  alias Dora.Events

  action_fallback DoraWeb.FallbackController

  def index(conn, %{"type" => type} = params) do
    events = Events.get_all_by_type(type, params)
    render(conn, "index.json", events: events)
  end
end
