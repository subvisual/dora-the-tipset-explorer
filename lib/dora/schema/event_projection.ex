defmodule Dora.Schema.EventProjection do
  use Ecto.Schema

  import Ecto.Changeset

  @fields [:contract_address, :projection_type, :projection_id, :projection_fields]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "event_projections" do
    field(:contract_address, :string)
    field(:projection_type, :string)
    field(:projection_id, :string)
    field(:projection_fields, :map)

    timestamps()
  end

  def changeset(indexer_store, params \\ %{}) do
    indexer_store
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:unique_projection_by_address, name: "projection_index")
  end
end
