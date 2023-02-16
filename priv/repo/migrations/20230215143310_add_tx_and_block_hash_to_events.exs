defmodule Dora.Repo.Migrations.AddTxAndBlockHashToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add(:tx_hash, :string)
      add(:block_hash, :string)
      add(:log_index, :string)
    end

    create(unique_index(:events, [:tx_hash, :log_index], name: :unique_event))
  end
end
