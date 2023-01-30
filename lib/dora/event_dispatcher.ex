defmodule Dora.EventDispatcher do
  def dispatch(contract_address, event) do
    [_name, event_type, _rest] = Regex.run(~r/(\w+)(\(.*\))/, event["name"])

    event_type
    |> Macro.underscore()
    |> handle(contract_address, event)
  end

  # If we want to deal with the event without worrying on the address
  # Default behaviour for all Transfer events
  def handle("transfer", address, event) do
    Dora.Handlers.Defaults.Transfer.apply(address, event)
  end

  def handle(_type, _address, _event), do: :ok
end
