defmodule Dora.Explorer.HttpRpc do
  require Logger
  use Tesla

  @http_rpc Application.compile_env!(:dora, :explorer)[:http_rpc_endpoint]

  plug(Tesla.Middleware.BaseUrl, @http_rpc)
  plug(Tesla.Middleware.Headers, [{"accept", "*/*"}])
  plug(Tesla.Middleware.JSON)

  def events(address, from_block) do
    body = %{
      id: 0,
      jsonrpc: "2.0",
      method: "Filecoin.EthGetLogs",
      params: [
        %{
          address: [address],
          fromBlock: to_string(from_block),
          toBlock: "latest"
        }
      ]
    }

    post("/", body)
    |> handle_events(address, from_block)
  end

  defp handle_events({:ok, %Tesla.Env{status: 200, body: body}}, _, _) do
    body["result"]
  end

  defp handle_events(_, address, from_block) do
    Logger.error("Error requesting events: #{address} from block: #{from_block}")
    []
  end
end
