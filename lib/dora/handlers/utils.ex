defmodule Dora.Handlers.Utils do
  def hex_string_to_integer(value) do
    value
    |> String.slice(2..-1)
    |> Integer.parse(16)
    |> elem(0)
  end

  def hex_string_to_eth_address(value) do
    "0x#{String.slice(value, -40..-1)}"
  end
end
