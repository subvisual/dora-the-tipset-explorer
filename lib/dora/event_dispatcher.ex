defmodule Dora.EventDispatcher do
  def dispatch(contract_address, event) do
    [_name, event_type, _rest] = Regex.run(~r/(\w+)(\(.+\))/, event["name"])

    handle(event_type, contract_address, event)
  end

  # If we wanted different handlers by Adddress
  # def handle(EVENT_NAME, "0x1234", event) do
  #   Dora.SomeModule.handle(address, event)
  # end

  # If we want to deal with the event without worrying on the address
  # Default behaviour for all Transfer events
  def handle("Transfer", address, event) do
    Dora.Handlers.Defaults.Transfer.apply(address, event)
  end

  # Injected comment at the end 
end
