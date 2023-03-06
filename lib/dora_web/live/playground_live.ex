defmodule DoraWeb.PlaygroundLive do
  use DoraWeb, :live_view
  alias Dora.{Contracts, Events, Projections}
  alias DoraWeb.{EventProjectionJSON, EventJSON}

  @refresh_rate Application.compile_env!(:dora, :explorer)[:refresh_rate]

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, @refresh_rate)

    event_types =
      Events.get_unique_types()
      |> Enum.map(&{&1.event_type, &1.event_type})

    contracts = Contracts.list_contracts()

    available_abis =
      if socket.assigns.current_user do
        Path.wildcard("priv/abis/*.json")
        |> Enum.map(&{List.last(String.split(&1, "/")), &1})
      else
        []
      end

    {:ok,
     assign(socket,
       current_user: socket.assigns.current_user,
       available_types: event_types,
       available_abis: available_abis,
       contracts: contracts,
       loading_contracts: [],
       model_type: "events",
       type: nil,
       filters: [],
       available_filters: [],
       results: ""
     )}
  end

  def handle_info(:update, socket) do
    event_types =
      Events.get_unique_types()
      |> Enum.map(&{&1.event_type, &1.event_type})

    contracts = Contracts.list_contracts()

    Process.send_after(self(), :update, @refresh_rate)

    {:noreply,
     assign(socket,
       available_types: event_types,
       contracts: contracts,
       loading_contracts: []
     )}
  end

  def handle_event("add-filter", _value, socket) do
    new_filters =
      socket.assigns.filters ++
        [
          %{
            "filter-key" => "",
            "filter-value" => ""
          }
        ]

    {:noreply, assign(socket, filters: new_filters)}
  end

  def handle_event("play", %{"address" => address}, socket) do
    if not is_nil(socket.assigns.current_user) do
      Dora.start_explorer_instance(address)
    end

    {:noreply, assign(socket, loading_contracts: [address | socket.assigns.loading_contracts])}
  end

  def handle_event("pause", %{"address" => address}, socket) do
    if not is_nil(socket.assigns.current_user) do
      Dora.pause_explorer_instance(address)
    end

    {:noreply, assign(socket, loading_contracts: [address | socket.assigns.loading_contracts])}
  end

  def handle_event("start-new-contract", %{"abi_path" => abi, "address" => address}, socket)
      when abi != "" and address != "" do
    socket =
      if not is_nil(socket.assigns.current_user) do
        Dora.start_explorer_instance(address, abi)

        put_flash(
          socket,
          :info,
          "Indexing Submitted! The new contract should appear in the list, shortly."
        )
      else
        put_flash(socket, :error, "Not signed in!")
      end

    {:noreply, socket}
  end

  def handle_event("start-new-contract", _value, socket) do
    socket =
      if not is_nil(socket.assigns.current_user) do
        put_flash(socket, :error, "Invalid arguments!")
      else
        put_flash(socket, :error, "Not signed in!")
      end

    {:noreply, socket}
  end

  def handle_event("remove-filter", %{"index" => index}, socket) do
    new_filters = List.delete_at(socket.assigns.filters, String.to_integer(index))
    {:noreply, assign(socket, filters: new_filters)}
  end

  def handle_event("validate", value, socket) do
    cond do
      value["_target"] == ["model-type"] && value["model-type"] != socket.assigns.model_type ->
        new_types = type_options(value["model-type"])

        {:noreply, assign(socket, available_types: new_types, model_type: value["model-type"])}

      value["_target"] == ["type"] ->
        available_filters = filter_options(value["model-type"], value["type"])
        {:noreply, assign(socket, type: value["type"], available_filters: available_filters)}

      String.match?(hd(value["_target"]), ~r/filter-key\d/) ->
        [_, index] = Regex.run(~r/filter-key(\d)/, hd(value["_target"]))

        new_filters =
          List.update_at(
            socket.assigns.filters,
            String.to_integer(index),
            &Map.put(&1, "filter-key", value["filter-key#{index}"])
          )

        {:noreply, assign(socket, filters: new_filters)}

      String.match?(hd(value["_target"]), ~r/filter-value\d/) ->
        [_, index] = Regex.run(~r/filter-value(\d)/, hd(value["_target"]))

        new_filters =
          List.update_at(
            socket.assigns.filters,
            String.to_integer(index),
            &Map.put(&1, "filter-value", value["filter-value#{index}"])
          )

        {:noreply, assign(socket, filters: new_filters)}

      true ->
        {:noreply, socket}
    end
  end

  def handle_event("search", value, socket) do
    filters =
      socket.assigns.filters
      |> Enum.reduce(%{}, &Map.put(&2, &1["filter-key"], &1["filter-value"]))

    results =
      case value["model-type"] do
        "events" ->
          events = Events.get_all_by_type(value["type"], filters)
          EventJSON.index(%{events: events})

        "projections" ->
          projections = Projections.get_all_by_type(value["type"], filters)

          EventProjectionJSON.index(%{event_projections: projections})
      end
      |> Jason.encode!(pretty: true)

    {:noreply, assign(socket, results: results)}
  end

  defp type_options(model_type) do
    case model_type do
      "events" ->
        Events.get_unique_types()
        |> Enum.map(&{&1.event_type, &1.event_type})

      "projections" ->
        Projections.get_unique_types()
        |> Enum.map(&{&1.projection_type, &1.projection_type})
    end
  end

  defp filter_options(model_type, type) do
    case model_type do
      "events" ->
        Events.get_unique_fields_for_type(type)
        |> Enum.map(&{&1, &1})

      "projections" ->
        Projections.get_unique_fields_for_type(type)
        |> Enum.map(&{&1, &1})
    end
  end
end
