defmodule DoraWeb.Helpers.Live do
  def map_to_query_string(filters) do
    query =
      filters
      |> Enum.reduce(%{}, &Map.put(&2, &1["filter-key"], &1["filter-value"]))
      |> URI.encode_query()

    if query != "", do: "?#{query}", else: ""
  end

  def pill_color(contract, running) do
    if Enum.any?(running, &(elem(&1, 0) == contract.address)) do
      "bg-green-100 text-green-500"
    else
      "bg-brand/5 text-brand"
    end
  end

  def status_description(contract, running) do
    if Enum.any?(running, &(elem(&1, 0) == contract.address)) do
      "Running"
    else
      "Paused"
    end
  end
end
