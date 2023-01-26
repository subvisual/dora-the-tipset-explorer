defmodule Dora.Events do
  alias Dora.Schema.Event
  alias Dora.Repo

  import Ecto.Query

  def get_all_by_type(type) do
    Event
    |> where(event_type: ^type)
    |> Repo.all()
  end
end
