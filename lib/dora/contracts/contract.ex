defmodule Dora.Contracts.Contract do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contracts" do
    field :abi_path, :string
    field :address, :string
    field :last_timestamp, :integer

    timestamps()
  end

  @doc false
  def changeset(contract, attrs) do
    contract
    |> cast(attrs, [:address, :last_timestamp, :abi_path])
    |> validate_required([:address, :last_timestamp, :abi_path])
    |> unique_constraint(:address, name: "contracts_address_index")
  end
end
