defmodule Dora.EventHandler do
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

  # def self_join() do
  #   Event
  #   |> where(
  #     [store],
  #     store.schema_args["topics"][2] ==
  #       ^"0x0000000000000000000000007c4f0ae91449b6224629b232970e49a82a90c8a2"
  #   )
  #   |> join(:left, [store], transfer in Event,
  #     # store.schema_args["address"]
  #     on:
  #       transfer.schema_args["topics"][3] ==
  #         ^"0x0000000000000000000000000000000000000000000000000000000000000002"
  #   )
  #   |> select([store, transfer], {store.id, store.schema_args, transfer.id})
  #   # from(indexer in Event,
  #   #   where:
  #   #     indexer.schema_args["topics"][2] ==
  #   #       ^"0x0000000000000000000000007c4f0ae91449b6224629b232970e49a82a90c8a2",
  #   #   inner_lateral_join: transfer in Event,
  #   #   # as: :transfer,
  #   #   on: transfer.schema_args["address"] == indexer.schema_args["address"]
  #   # )
  #   |> Repo.all()
  # end
end
