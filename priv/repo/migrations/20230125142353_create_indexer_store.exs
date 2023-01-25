defmodule Dora.Repo.Migrations.CreateEventsStore do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:contract_address, :string)
      add(:event_type, :string)
      add(:event_args, :map)

      timestamps()
    end

    create(index("events", [:contract_address, :event_type]))
  end
end
