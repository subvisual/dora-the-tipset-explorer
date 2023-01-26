defmodule Dora.Explorer.Filfox do
  require Logger
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://hyperspace.filfox.info/api/v1")
  plug(Tesla.Middleware.Headers, [{"accept", "*/*"}])
  plug(Tesla.Middleware.JSON)

  def address_messages(address) do
    get("/address/#{address}/messages")
    |> handle_messages(address)
  end

  def message(message_cid) do
    get("/message/#{message_cid}")
    |> handle_message(message_cid)
  end

  defp handle_messages({:ok, %Tesla.Env{status: 200, body: body}}, _address) do
    body["messages"]
  end

  defp handle_messages(_, address) do
    Logger.error("Error requesting messages for address: #{address}")
    []
  end

  defp handle_message({:ok, %Tesla.Env{status: 200, body: body}}, _cid) do
    body["eventLogs"]
  end

  defp handle_message(_, message_cid) do
    Logger.error("Error requesting message cid: #{message_cid}")
    [%{error: message_cid}]
  end
end
