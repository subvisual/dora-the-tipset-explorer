defmodule Dora.ContractsTest do
  use Dora.DataCase

  alias Dora.Contracts

  describe "contracts" do
    alias Dora.Contracts.Contract

    import Dora.ContractsFixtures

    @invalid_attrs %{abi_path: nil, address: nil, last_timestamp: nil}

    test "list_contracts/0 returns all contracts" do
      contract = contract_fixture()
      assert Contracts.list_contracts() == [contract]
    end

    test "get_contract!/1 returns the contract with given id" do
      contract = contract_fixture()
      assert Contracts.get_contract!(contract.id) == contract
    end

    test "create_contract/1 with valid data creates a contract" do
      valid_attrs = %{abi_path: "some abi_path", address: "some address", last_timestamp: 42}

      assert {:ok, %Contract{} = contract} = Contracts.create_contract(valid_attrs)
      assert contract.abi_path == "some abi_path"
      assert contract.address == "some address"
      assert contract.last_timestamp == 42
    end

    test "create_contract/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contracts.create_contract(@invalid_attrs)
    end

    test "update_contract/2 with valid data updates the contract" do
      contract = contract_fixture()

      update_attrs = %{
        abi_path: "some updated abi_path",
        address: "some updated address",
        last_timestamp: 43
      }

      assert {:ok, %Contract{} = contract} = Contracts.update_contract(contract, update_attrs)
      assert contract.abi_path == "some updated abi_path"
      assert contract.address == "some updated address"
      assert contract.last_timestamp == 43
    end

    test "update_contract/2 with invalid data returns error changeset" do
      contract = contract_fixture()
      assert {:error, %Ecto.Changeset{}} = Contracts.update_contract(contract, @invalid_attrs)
      assert contract == Contracts.get_contract!(contract.id)
    end

    test "delete_contract/1 deletes the contract" do
      contract = contract_fixture()
      assert {:ok, %Contract{}} = Contracts.delete_contract(contract)
      assert_raise Ecto.NoResultsError, fn -> Contracts.get_contract!(contract.id) end
    end

    test "change_contract/1 returns a contract changeset" do
      contract = contract_fixture()
      assert %Ecto.Changeset{} = Contracts.change_contract(contract)
    end
  end
end
