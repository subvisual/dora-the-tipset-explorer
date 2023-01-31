defmodule Mix.Tasks.Utils do
  require Logger

  @event_dispatcher_path "lib/dora/event_dispatcher.ex"

  def parse_abi(nil), do: nil

  def parse_abi(abi_path) do
    abi =
      abi_path
      |> File.read!()
      |> Jason.decode!()

    specification = abi["output"]["abi"] || abi["abi"]

    Enum.reduce(specification, %{}, fn entry, acc ->
      if entry["type"] == "event" do
        inputs = Enum.map(entry["inputs"], &%{name: &1["name"], type: &1["type"]})

        Map.put(acc, entry["name"], inputs)
      else
        acc
      end
    end)
  rescue
    error ->
      Logger.error("""
      Have you checked if the file exists?

      #{inspect(error)}
      """)
  end

  def insert_new_dispatcher_handler(module, event_name, nil) do
    content_to_replace = "def handle(type, address, _event) do\n"

    content_to_inject =
      """
      def handle("#{event_name}", address, event) do
          Dora.Handlers.Defaults.#{module}.apply(address, event)
        end

      """ <> "  #{content_to_replace}"

    inject_eex_in_place(content_to_replace, content_to_inject, @event_dispatcher_path)
  end

  def insert_new_dispatcher_handler(module, event_name, contract_address) do
    content_to_replace = "|> handle(contract_address, {abi_selector, decoded_event})\n  end\n"

    content_to_inject =
      "#{content_to_replace} \n" <>
        """
          def handle("#{event_name}", "#{contract_address}", event) do
            Dora.Handlers.Contracts.#{module}.apply("#{event_name}", "#{contract_address}", event)
          end
        """

    inject_eex_in_place(content_to_replace, content_to_inject, @event_dispatcher_path)
  end

  # TODO: Update this to inject before default handler and not last end
  def inject_eex_in_place(content_to_replace, content_to_inject, file_path) do
    file = File.read!(file_path)

    if String.contains?(file, content_to_inject) do
      :ok
    else
      Mix.shell().info([:green, "* injecting ", :reset, Path.relative_to_cwd(file_path)])

      file
      |> String.replace(content_to_replace, content_to_inject)
      |> write_file(file_path)
    end
  end

  defp write_file(content, file) do
    File.write!(file, content)
  end
end
