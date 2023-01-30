defmodule Dora do
  require Logger

  alias Dora.{Explorer}

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
    base_state = %{address: address, abi_path: abi_path}

    state =
      case :dets.lookup(:addresses, address) do
        [] -> base_state
        [{_key, timestamp, _}] -> Map.put(base_state, :last_timestamp, timestamp)
      end

    spec = {Explorer, state}

    with {:error, error} <- DynamicSupervisor.start_child(__MODULE__, spec) do
      Logger.error("Error indexing contract #{address}: #{inspect(error)}")
    end
  end

  def stop_explorer_instance(address) do
    pause_explorer_instance(address)
    :dets.delete(:addresses, address)
  end

  def pause_explorer_instance(address) do
    with {:ok, pid} <- get_pid_explorer_instance(address) do
      Explorer.stop(pid)

      {:ok, :closed}
    end
  end

  def get_pid_explorer_instance(address) do
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

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp restore_previous_state do
    if :ets.whereis(:address_instances) == :undefined do
      :ets.new(:address_instances, [:set, :public, :named_table])
    end

    :dets.match_object(:addresses, {:_, :_, :_})
    |> Enum.each(fn {address, _timestamp, abi_path} ->
      start_explorer_instance(address, abi_path)
    end)
  end
end
