defmodule Dora.Contracts.Contract do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contracts" do
    field :abi_path, :string
    field :address, :string
    field :last_block, :integer
    field :last_run, :naive_datetime

    field :status, Ecto.Enum,
      values: [:running, :paused],
      default: :running

    timestamps()
  end

  @doc false
  def changeset(contract, attrs) do
    contract
    |> cast(attrs, [:address, :last_block, :abi_path, :status, :last_run])
    |> validate_required([:address, :last_block, :abi_path])
    |> unique_constraint(:address, name: "contracts_address_index")
  end
end
