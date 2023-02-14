defmodule Dora.EventDispatcher do
  require Logger

  def dispatch(contract_address, {:error, decoded_event}) do
    Logger.error(
      "Couldn't find a matching Event for #{contract_address}: #{inspect(decoded_event)}"
    )
  end

  def dispatch(contract_address, {abi_selector, decoded_event}) do
    event_type = abi_selector.function

    event_type
    |> Macro.underscore()
    |> handle(contract_address, {abi_selector, decoded_event})
  end

  # If we want to deal with the event without worrying on the address
  # Default behaviour for all Transfer events
  #
  # Remove this if you don't need it in your handlers
  def handle("transfer", address, event) do
    Dora.Handlers.Defaults.Transfer.apply(address, event)
  end

  def handle(type, address, _event) do
    Logger.warning("Ignoring event #{type} from #{address}.")
  end
end
