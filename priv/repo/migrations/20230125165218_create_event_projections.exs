defmodule Dora.Repo.Migrations.CreateEventProjections do
  use Ecto.Migration

  def change do
    create table(:event_projections, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:contract_address, :string)
      add(:projection_type, :string)
      add(:projection_id, :string)
      add(:projection_fields, :map)

      timestamps()
    end

    create(
      index("event_projections", [:contract_address, :projection_type, :projection_id],
        name: "projection_index"
      )
    )
  end
end
