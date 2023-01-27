defmodule Mix.Tasks.Dora.Gen.Handler do
  @shortdoc "Generates an Handler for Events"

  require Logger
  use Mix.Task

  # @switches [migration: :boolean, binary_id: :boolean, table: :string,
  # web: :string, context_app: :string, prefix: :string]
  @switches [contract: :string, address: :string]

  @template_path "priv/templates/dora.gen.handler/handler.ex"
  @base_output_path "lib/dora/handlers"

  def run([module | _rest] = args) do
    IO.inspect(args)

    type = Macro.underscore(module)
    prefix = if is_contract?(args), do: "Contracts", else: "Defaults"

    template_data = [
      module_name: module,
      event_type: type,
      contract: is_contract?(args),
      module_prefix: prefix,
      file_output: "#{@base_output_path}/#{String.downcase(prefix)}/#{type}.ex"
    ]

    Mix.Generator.copy_template(@template_path, template_data[:file_output], template_data)

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
