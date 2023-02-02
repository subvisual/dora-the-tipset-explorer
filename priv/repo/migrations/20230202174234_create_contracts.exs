defmodule Dora.Repo.Migrations.CreateContracts do
  use Ecto.Migration

  def change do
    create table(:contracts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:address, :string)
      add(:last_timestamp, :integer)
      add(:abi_path, :string)

      timestamps()
    end

    create(index("contracts", :address))
  end
end
