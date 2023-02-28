defmodule Dora.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :eth_address, :string
    field :nonce, :string

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:eth_address, :nonce])
    |> validate_required([:eth_address, :nonce])
    |> unique_constraint([:eth_address])
  end
end
