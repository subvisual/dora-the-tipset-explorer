defmodule Dora.Explorer do
  require Logger
  use GenServer, restart: :transient

  alias Dora.Explorer.Filfox
  alias Dora.EventDispatcher
  alias Dora.Handlers.Utils

  @refresh_rate Application.compile_env!(:dora, :explorer)[:refresh_rate]

  def start_link(args) do
    {:ok, pid} = GenServer.start_link(__MODULE__, args)

    Dora.insert_instance_in_ets(args.address, pid)
    send(pid, :start)
    Logger.info("Indexing #{args.address}. Last Timestamp: #{Map.get(args, :last_timestamp, 0)}.")

    {:ok, pid}
  end

  def stop(address) do
    GenServer.stop(address)
  end

  @impl true
  def init(init_arg) do
    abi = abi_specification(init_arg.abi_path)

    new_state =
      init_arg
      |> Map.put_new(:last_timestamp, 0)
      |> Map.put(:abi, abi)

    {:ok, new_state}
  end

  @impl true
  def handle_info(:start, state) do
    messages =
      Filfox.address_messages(state.address)
      |> Enum.filter(&filter_message?(&1, state.last_timestamp))

    send(self(), {:new_messages, messages})
    Process.send_after(self(), :start, @refresh_rate)

    new_state =
      if messages != [] do
        Dora.store_contract_information(state.address, hd(messages)["timestamp"], state.abi_path)

        Map.put(state, :last_timestamp, hd(messages)["timestamp"])
      else
        state
      end

    {:noreply, new_state}
  end

  @impl true
  def handle_info({:new_messages, messages}, state) do
    Enum.map(messages, &Filfox.message(&1["cid"]))
    |> List.flatten()
    |> tap(&Logger.info("Detected #{length(&1)} new messages for: #{state.address}"))
    |> Enum.each(&handle_message_content(state, &1))

    {:noreply, state}
  end

  @impl true
  def handle_info({:retry_message, message_cid}, state) do
    Filfox.message(message_cid)
    |> List.flatten()
    |> Enum.each(&handle_message_content(state, &1))

    {:noreply, state}
  end

  defp filter_message?(message, last_timestamp) do
    message["timestamp"] > last_timestamp
  end

  defp handle_message_content(_state, %{error: message_cid}) do
    Logger.warning("Retrying message: #{message_cid}")
    send(self(), {:retry_message, message_cid})
  end

  defp handle_message_content(state, message) do
    topics = message["topics"]

    decoded_event =
      ABI.Event.find_and_decode(
        state.abi,
        Utils.hex_to_string(Enum.at(topics, 0)),
        Utils.hex_to_string(Enum.at(topics, 1)),
        Utils.hex_to_string(Enum.at(topics, 2)),
        Utils.hex_to_string(Enum.at(topics, 3)),
        Utils.pad_data_string(message["data"])
      )

    EventDispatcher.dispatch(state.address, decoded_event)
  end

  defp abi_specification(abi_path) do
    abi_json =
      abi_path
      |> File.read!()
      |> Jason.decode()

    with {:ok, specification} <- abi_json do
      (specification["abi"] || specification["output"]["abi"])
      |> ABI.parse_specification(include_events?: true)
    else
      {:error, error} -> Logger.error("Error building ABI spec: #{inspect(error)}")
    end
  end
end
