defmodule Dora.ContractsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dora.Contracts` context.
  """

  @doc """
  Generate a contract.
  """
  def contract_fixture(attrs \\ %{}) do
    {:ok, contract} =
      attrs
      |> Enum.into(%{
        abi_path: "some abi_path",
        address: "some address",
        last_timestamp: 42
      })
      |> Dora.Contracts.create_contract()

    contract
  end
end
