defmodule Dora.Schema.Event do
  use Ecto.Schema

  import Ecto.Changeset

  @fields [:contract_address, :event_type, :event_args]

  @derive {Jason.Encoder, only: [:contract_address, :event_args]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "events" do
    field(:contract_address, :string)
    field(:event_type, :string)
    field(:event_args, :map)

    timestamps()
  end

  def changeset(indexer_store, params \\ %{}) do
    indexer_store
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
