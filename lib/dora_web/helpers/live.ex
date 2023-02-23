defmodule DoraWeb.Helpers.Live do
  def map_to_query_string(filters) do
    query =
      filters
      |> Enum.reduce(%{}, &Map.put(&2, &1["filter-key"], &1["filter-value"]))
      |> URI.encode_query()

    if query != "", do: "?#{query}", else: ""
  end
end
