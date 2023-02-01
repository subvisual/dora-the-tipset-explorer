defmodule DoraWeb.ProjectionController do
  use DoraWeb, :controller

  alias Dora.Projections

  action_fallback DoraWeb.FallbackController

  def index(conn, %{"type" => type} = params) do
    event_projections = Projections.get_all_by_type(type, params)
    render(conn, "index.json", projections: event_projections)
  end
end
