defmodule Dora.Handlers.Utils do
  def hex_to_integer_string(value) do
    value
    |> String.slice(2..-1)
    |> Integer.parse(16)
    |> elem(0)
    |> Integer.to_string()
  end

  def hex_to_eth_address(value) do
    "0x#{String.slice(value, -40..-1)}"
  end

  def hex_to_string("0x" <> value) do
    Base.decode16!(value, case: :mixed)
  end
end
