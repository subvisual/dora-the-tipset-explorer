defmodule DoraWeb.EventProjectionJSON do
  alias Dora.Projections.EventProjection

  @doc """
  Renders a list of event_projections.
  """
  def index(%{event_projections: event_projections}) do
    %{data: for(event_projection <- event_projections, do: data(event_projection))}
  end

  @doc """
  Renders a single event_projection.
  """
  def show(%{event_projection: event_projection}) do
    %{data: data(event_projection)}
  end

  defp data(%EventProjection{} = projection) do
    %{
      contract_address: projection.contract_address,
      projection_id: projection.projection_id,
      projection_type: projection.projection_type,
      projection_fields: projection.projection_fields,
      inserted_at: projection.inserted_at
    }
  end
end
