defmodule DoraWeb.Helpers.Live do
  def map_to_query_string(filters) do
    query =
      filters
      |> Enum.reduce(%{}, &Map.put(&2, &1["filter-key"], &1["filter-value"]))
      |> URI.encode_query()

    if query != "", do: "?#{query}", else: ""
  end

  def pill_color(contract) do
    if contract.status == :running do
      "bg-green-100 text-green-500"
    else
      "bg-orange/5 text-orange"
    end
  end

  def status_description(contract) do
    if contract.status == :running do
      "Running"
    else
      "Paused"
    end
  end
end
