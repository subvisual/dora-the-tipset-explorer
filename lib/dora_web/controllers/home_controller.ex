defmodule DoraWeb.HomeController do
  use DoraWeb, :controller

  action_fallback DoraWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.json")
  end
end
