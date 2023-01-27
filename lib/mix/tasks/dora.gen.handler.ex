defmodule Mix.Tasks.Dora.Gen.Handler do
  @shortdoc "Generates an Handler for Events"

  require Logger
  use Mix.Task

  alias Mix.Tasks.Utils

  @template_path "priv/templates/dora.gen.handler/handler.ex"
  @base_output_path "lib/dora/handlers"
  @dispatcher_path "lib/dora/event_dispatcher.ex"

  def run([module | _rest] = args) do
    type = Macro.underscore(module)
    prefix = if is_contract?(args), do: "Contracts", else: "Defaults"

    template_data = [
      module_name: module,
      event_type: type,
      contract: is_contract?(args),
      module_prefix: prefix,
      file_output: "#{@base_output_path}/#{String.downcase(prefix)}/#{type}.ex"
    ]

    # Mix.Generator.copy_template(@template_path, template_data[:file_output], template_data)

    # Utils.inject_eex_before_final_end("\t # Injected comment at the end \n", @dispatcher_path, [])

    Utils.parse_abi("lib/mix/tasks/erc20.json")

    IO.puts("Event #{args} generated")
  end

  def run(args) do
    Logger.error("""
    Invalid #{inspect(args)}.
    Expected at least the Contract/Event name, in camel case. Example:

    $ mix dora.gen.handler TransferNft
    """)
  end

  defp is_contract?(args) do
    Enum.any?(args, &String.match?(&1, ~r/contract:[\w, \d]+/))
  end
end
