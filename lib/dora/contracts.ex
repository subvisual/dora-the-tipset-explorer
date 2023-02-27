defmodule Dora.Contracts do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Dora.Repo
  alias Dora.Contracts.Contract

  def list_contracts(filters) when is_list(filters) do
    Contract
    |> where(^filters)
    |> order_by([:inserted_at])
    |> Repo.all()
  end

  def list_contracts do
    Contract
    |> order_by([:inserted_at])
    |> Repo.all()
  end

  def get_contract!(id), do: Repo.get!(Contract, id)

  def get_contract_by_address(address), do: Repo.get_by(Contract, address: address)

  def contract_information(address) do
    case Repo.get_by(Contract, address: address) do
      nil -> {0, nil}
      contract -> {contract.last_block, contract.abi_path}
    end
  end

  def create_or_update_contract(address, attrs \\ %{}) do
    case Repo.get_by(Contract, address: address) do
      nil -> create_contract(attrs)
      contract -> update_contract(contract, attrs)
    end
  end

  def create_contract(attrs \\ %{}) do
    %Contract{}
    |> Contract.changeset(attrs)
    |> Repo.insert()
  end

  def update_contract(address, attrs) when is_binary(address) do
    Contract
    |> Repo.get_by!(address: address)
    |> Contract.changeset(attrs)
    |> Repo.update()
  end

  def update_contract(%Contract{} = contract, attrs) do
    contract
    |> Contract.changeset(attrs)
    |> Repo.update()
  end

  def delete_contract(address) when is_binary(address) do
    Contract
    |> Repo.get_by!(address: address)
    |> Repo.delete()
  end

  def delete_contract(%Contract{} = contract) do
    Repo.delete(contract)
  end

  def change_contract(%Contract{} = contract, attrs \\ %{}) do
    Contract.changeset(contract, attrs)
  end
end
