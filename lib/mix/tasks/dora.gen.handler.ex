defmodule Mix.Tasks.Dora.Gen.Handler do
  @shortdoc "Generates an Handler for Events"

  require Logger
  use Mix.Task

  alias Mix.Tasks.Utils

  @template_path "priv/templates/dora.gen.handler/handler.ex"
  @base_output_path "lib/dora/handlers"
  @contract_regex ~r/contract:([\w, \d]+)/
  @abi_regex ~r/abi:([\w, \d, _, \s, -, \+, \., \/]+.json)/

  def run([module | _rest] = args) do
    type = Macro.underscore(module)
    is_contract = is_contract?(args)
    prefix = if is_contract, do: "Contracts", else: "Defaults"
    address = if is_contract, do: get_contract_address(args), else: nil

    abi =
      get_abi_path(args)
      |> Utils.parse_abi()

    abi =
      if not is_contract do
        Enum.filter(abi, fn {key, _value} -> key == module end)
      else
        abi
      end

    template_data = [
      module_name: module,
      event_type: type,
      address: address,
      module_prefix: prefix,
      file_output: "#{@base_output_path}/#{String.downcase(prefix)}/#{type}.ex",
      abi: abi
    ]

    if abi != %{},
      do: Mix.Generator.copy_template(@template_path, template_data[:file_output], template_data)

    Enum.each(abi, fn {event_name, _args} ->
      Utils.insert_new_dispatcher_handler(module, Macro.underscore(event_name), address)
    end)

    IO.puts("""

    -------

    Handler #{module} generated!

    Don't forget to check all generated and touched files.
    They may require some changes for your needs.

    You may also want to take a look at:

     - lib/dora/events.ex
     - lib/dora/event_projections.ex

    These files are where API related things are handled.
    If you need more filters, add them there, respectively.
    """)
  end

  def run(args) do
    Logger.error("""
    Invalid args: #{inspect(args)}.
    Expected at least the Contract/Event name, in camel case, and the ABI path.

    -------

    Example for a catch all Event type handler:
    $ mix dora.gen.handler Transfer abi:some_path/erc20.json

    Example for a contract specific handler:
    $ mix dora.gen.handler ERC20 contractL:0x1234 abi:some_path/erc20.json
    """)
  end

  defp is_contract?(args) do
    Enum.any?(args, &String.match?(&1, @contract_regex))
  end

  defp get_contract_address(args) do
    [_contract, address] =
      Enum.filter(args, &String.match?(&1, @contract_regex))
      |> hd()
      |> String.split(":")

    String.downcase(address)
  end

  defp get_abi_path(args) do
    Enum.filter(args, &String.match?(&1, @abi_regex))
    |> case do
      [] ->
        raise "There should be an ABI file. You can pass one using abi:path/to/file.json"

      [match] ->
        [_abi, path] = String.split(match, ":")
        path
    end
  end
end
