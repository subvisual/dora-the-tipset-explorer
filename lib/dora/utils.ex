defmodule Dora.Utils do
  @moduledoc false

  require Logger

  def build_topics_maps(topics) do
    Enum.reduce(topics, %{}, fn {name, type, _indexed, value}, acc ->
      Map.put(acc, name, parse_value(value, type))
    end)
  end

  def hex_to_string("0x" <> value) do
    Base.decode16!(value, case: :mixed)
  end

  def hex_to_string(nil), do: nil

  def pad_data_string("0x" <> data) do
    String.pad_leading(data, 64, "0")
    |> Base.decode16!(case: :mixed)
  end

  def hex_to_int("0x" <> value), do: String.to_integer(value, 16)
  def hex_to_int(value), do: Logger.error("Invalid hex value: #{value}")

  def int_to_hex("latest"), do: "latest"
  def int_to_hex(value) when is_integer(value), do: "0x#{Integer.to_string(value, 16)}"

  defp parse_value(value, "address") when is_binary(value),
    do: String.downcase("0x#{Base.encode16(value)}")

  defp parse_value(value, "string") when is_binary(value), do: Base.encode16(value)
  defp parse_value(value, "uint256") when is_number(value), do: Integer.to_string(value)
  defp parse_value(value, _), do: value
end
