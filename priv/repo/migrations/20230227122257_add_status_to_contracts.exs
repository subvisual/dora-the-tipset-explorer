defmodule Dora.Repo.Migrations.AddStatusToContracts do
  use Ecto.Migration

  def change do
    alter table(:contracts) do
      add :status, :string, default: "running", null: false
      add :last_run, :naive_datetime
    end
  end
end
