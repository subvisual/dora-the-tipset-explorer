defmodule Dora.Events.Event do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @fields [:contract_address, :event_type, :event_args, :block_hash, :tx_hash, :log_index]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "events" do
    field(:contract_address, :string)
    field(:event_type, :string)
    field(:event_args, :map)
    field(:block_hash, :string)
    field(:tx_hash, :string)
    field(:log_index, :string)

    timestamps()
  end

  def changeset(indexer_store, params \\ %{}) do
    indexer_store
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint([:tx_hash, :log_index])
  end
end
