defmodule Dora.Explorer.HttpRpc do
  @moduledoc false

  require Logger
  use Tesla

  alias Dora.Utils

  @maximum_blocks_from_the_past 2_500

  plug(Tesla.Middleware.BaseUrl, get_rpc_endpoint())
  plug(Tesla.Middleware.Headers, [{"accept", "*/*"}])
  plug(Tesla.Middleware.JSON)

  def latest_block do
    body = %{
      id: UUID.uuid4(),
      jsonrpc: "2.0",
      method: "eth_blockNumber",
      params: []
    }

    post("/", body)
    |> handle_block_number()
  end

  def events(address, from_block) do
    latest_block = latest_block()

    {from, to} =
      if latest_block - @maximum_blocks_from_the_past > from_block do
        {from_block, from_block + @maximum_blocks_from_the_past}
      else
        {from_block, latest_block}
      end

    body = %{
      id: 0,
      jsonrpc: "2.0",
      method: "eth_getLogs",
      params: [
        %{
          address: [address],
          fromBlock: Utils.int_to_hex(from),
          toBlock: Utils.int_to_hex(to)
        }
      ]
    }

    events =
      post("/", body)
      |> handle_events(address, from_block)

    {Utils.int_to_hex(to), events}
  end

  defp handle_block_number({:ok, %Tesla.Env{status: 200, body: body}}) do
    Utils.hex_to_int(body["result"])
  end

  defp handle_block_number(_) do
    Logger.error("Error requesting latest block")
    0
  end

  defp handle_events({:ok, %Tesla.Env{status: 200, body: %{"error" => error}}}, address, _) do
    Logger.error("Error requesting events: #{address}. Error #{inspect(error)}")
    []
  end

  defp handle_events({:ok, %Tesla.Env{status: 200, body: body}}, _, _) do
    body["result"]
  end

  defp handle_events(_, address, from_block) do
    Logger.error("Error requesting events: #{address} from block: #{from_block}")
    []
  end

  defp get_rpc_endpoint do
    System.get_env("HTTP_RPC_ENDPOINT") ||
      raise """
      environment variable HTTP_RPC_ENDPOINT is missing.
      For example: https://api.hyperspace.node.glif.io/rpc/v1
      """
  end
end
