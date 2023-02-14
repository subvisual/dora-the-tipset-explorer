defmodule Dora.Explorer do
  require Logger
  use GenServer, restart: :transient

  alias Dora.Explorer.HttpRpc
  alias Dora.EventDispatcher
  alias Dora.Handlers.Utils

  @refresh_rate Application.compile_env!(:dora, :explorer)[:refresh_rate]

  def start_link(args) do
    {:ok, pid} = GenServer.start_link(__MODULE__, args)

    Dora.insert_instance_in_ets(args.address, pid)
    send(pid, :request_logs)
    Logger.info("Indexing #{args.address}. Last Block: #{Map.get(args, :last_block, 0)}.")

    {:ok, pid}
  end

  def stop(address) do
    GenServer.stop(address)
  end

  @impl true
  def init(init_arg) do
    case abi_specification(init_arg.abi_path) do
      {:ok, abi} ->
        new_state =
          init_arg
          |> Map.put_new(:last_block, 0)
          |> Map.put(:abi, abi)

        {:ok, new_state}

      error ->
        error
    end
  end

  @impl true
  def handle_info(:request_logs, state) do
    events =
      HttpRpc.events(state.address, state.last_block)
      |> tap(&Logger.info("Detected #{length(&1)} new Events for: #{state.address}"))
      |> Enum.sort_by(&hex_to_int(&1["blockNumber"]))

    Enum.each(events, &handle_event(state, &1))
    Process.send_after(self(), :request_logs, @refresh_rate)

    new_state = update_last_block_known(state, events)

    {:noreply, new_state}
  end

  defp handle_event(state, message) do
    topics = message["topics"] || []

    decoded_event =
      ABI.Event.find_and_decode(
        state.abi,
        Utils.hex_to_string(Enum.at(topics, 0)),
        Utils.hex_to_string(Enum.at(topics, 1)),
        Utils.hex_to_string(Enum.at(topics, 2)),
        Utils.hex_to_string(Enum.at(topics, 3)),
        Utils.pad_data_string(message["data"] || "0x")
      )

    EventDispatcher.dispatch(state.address, decoded_event)
  end

  defp update_last_block_known(state, []), do: state

  defp update_last_block_known(state, events) do
    last_block =
      List.last(events)["blockNumber"]
      |> hex_to_int()

    Dora.store_contract_information(
      state.address,
      last_block,
      state.abi_path
    )

    Map.put(state, :last_block, last_block)
  end

  defp abi_specification(abi_path) do
    with {:ok, binary} <- File.read(abi_path) do
      specification = Jason.decode!(binary)

      abi =
        (specification["abi"] || specification["output"]["abi"])
        |> ABI.parse_specification(include_events?: true)

      {:ok, abi}
    else
      error ->
        Logger.error("Error building ABI spec. Check if the File exists!")
        error
    end
  end

  defp hex_to_int("0x" <> value), do: String.to_integer(value, 16)
  defp hex_to_int(value), do: Logger.error("Invalid hex value: #{value}")
end
