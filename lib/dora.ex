defmodule Dora do
  require Logger

  alias Dora.{Explorer, Contracts}

  use DynamicSupervisor

  def start_link(init_arg) do
    with {:ok, pid} <- DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__) do
      :dets.open_file(:addresses, [])

      restore_previous_state()

      {:ok, pid}
    else
      _error ->
        Logger.error("Error starting Dora")
    end
  end

  def start_explorer_instance(address, abi_path) do
    address = String.downcase(address)

    state =
      %{address: address, abi_path: abi_path}
      |> contract_last_block(address)

    spec = {Explorer, state}

    with {:error, error} <- DynamicSupervisor.start_child(__MODULE__, spec) do
      Logger.error("Error indexing contract #{address}: #{inspect(error)}")
    end
  end

  def stop_explorer_instance(address) do
    address = String.downcase(address)

    pause_explorer_instance(address)
    :dets.delete(:addresses, address)
    Contracts.delete_contract(address)
  end

  def pause_explorer_instance(address) do
    with {:ok, pid} <- get_pid_explorer_instance(address) do
      Explorer.stop(pid)

      {:ok, :closed}
    end
  end

  def get_pid_explorer_instance(address) do
    address = String.downcase(address)

    case :ets.lookup(:address_instances, address) do
      [] -> {:error, :not_found}
      [{_address, pid}] -> {:ok, pid}
    end
  end

  def delete_instance_from_ets(address) do
    :ets.delete(:address_instances, address)
  end

  def insert_instance_in_ets(address, pid) do
    :ets.insert(:address_instances, {address, pid})
  end

  def store_contract_information(address, block_number, abi_path) do
    :dets.insert(:addresses, {address, block_number, abi_path})

    Dora.Contracts.create_or_update_contract(address, %{
      address: address,
      last_block: block_number,
      abi_path: abi_path
    })
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp restore_previous_state do
    if :ets.whereis(:address_instances) == :undefined do
      :ets.new(:address_instances, [:set, :public, :named_table])
    end

    :dets.match_object(:addresses, {:_, :_, :_})
    |> case do
      [] ->
        Contracts.list_contracts()
        |> Enum.each(&start_explorer_instance(&1.address, &1.abi_path))

      list ->
        Enum.each(list, fn {address, _block, abi_path} ->
          start_explorer_instance(address, abi_path)
        end)
    end
  end

  defp contract_last_block(base_state, address) do
    last_block =
      case :dets.lookup(:addresses, address) do
        [] -> {:error, :not_found}
        [{_key, block, _}] -> {:ok, block}
      end
      |> case do
        {:error, :not_found} -> Contracts.contract_last_block(address)
        {:ok, block} -> block
      end

    Map.put(base_state, :last_block, last_block)
  end
end
