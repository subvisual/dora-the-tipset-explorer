defmodule Dora.Repo.Migrations.RenameLastTimestampInContracts do
  use Ecto.Migration

  def change do
    rename(table(:contracts), :last_timestamp, to: :last_block)
  end
end
