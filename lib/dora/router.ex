defmodule Dora.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/events/:type" do
    body =
      type
      |> Dora.Events.get_all_by_type()
      |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, body)
  end

  match _ do
    body = Jason.encode!(%{error: :not_found})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, body)
  end
end
