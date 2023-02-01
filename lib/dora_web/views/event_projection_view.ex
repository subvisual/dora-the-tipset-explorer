defmodule DoraWeb.ProjectionView do
  use DoraWeb, :view
  alias DoraWeb.ProjectionView

  def render("index.json", %{projections: projections}) do
    %{data: render_many(projections, ProjectionView, "projection.json")}
  end

  def render("show.json", %{projection: projection}) do
    %{data: render_one(projection, ProjectionView, "projection.json")}
  end

  def render("projection.json", %{projection: projection}) do
    %{
      contract_address: projection.contract_address,
      projection_id: projection.projection_id,
      projection_type: projection.projection_type,
      projection_fields: projection.projection_fields,
      inserted_at: projection.inserted_at
    }
  end
end
