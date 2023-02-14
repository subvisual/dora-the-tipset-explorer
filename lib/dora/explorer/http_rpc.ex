defmodule Dora.Explorer.HttpRpc do
  @moduledoc false

  require Logger
  use Tesla

  alias Dora.Utils

  @http_rpc Application.compile_env!(:dora, :explorer)[:http_rpc_endpoint]
  @maximum_blocks_from_the_past 60_400

  plug(Tesla.Middleware.BaseUrl, @http_rpc)
  plug(Tesla.Middleware.Headers, [{"accept", "*/*"}])
  plug(Tesla.Middleware.JSON)

  def latest_block do
    body = %{
      id: 1,
      jsonrpc: "2.0",
      method: "Filecoin.EthBlockNumber",
      params: []
    }

    post("/", body)
    |> handle_block_number()
  end

  def events(address, from_block) do
    {from, to} =
      if latest_block() - @maximum_blocks_from_the_past > from_block do
        {from_block, from_block + @maximum_blocks_from_the_past}
      else
        {from_block, "latest"}
      end

    body = %{
      id: 0,
      jsonrpc: "2.0",
      method: "Filecoin.EthGetLogs",
      params: [
        %{
          address: [address],
          fromBlock: Utils.int_to_hex(from),
          toBlock: Utils.int_to_hex(to)
        }
      ]
    }

    post("/", body)
    |> handle_events(address, from_block)
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
end
