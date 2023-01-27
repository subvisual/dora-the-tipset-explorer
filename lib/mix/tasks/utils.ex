defmodule Mix.Tasks.Utils do
  def parse_abi(abi_path) do
    IO.inspect(abi_path)

    abi =
      abi_path
      |> File.read!()
      |> Jason.decode!()

    Enum.reduce(abi["output"]["abi"], %{}, fn entry, acc ->
      if entry["type"] == "event" do
        inputs = Enum.map(entry["inputs"], &%{name: &1["name"], type: &1["type"]})

        Map.put(acc, entry["name"], inputs)
      else
        acc
      end
    end)
    |> IO.inspect()
  end

  def inject_eex_before_final_end(content_to_inject, file_path, binding) do
    file = File.read!(file_path)

    if String.contains?(file, content_to_inject) do
      :ok
    else
      Mix.shell().info([:green, "* injecting ", :reset, Path.relative_to_cwd(file_path)])

      file
      |> String.trim_trailing()
      |> String.trim_trailing("end")
      |> EEx.eval_string(binding)
      |> Kernel.<>(content_to_inject)
      |> Kernel.<>("end\n")
      |> write_file(file_path)
    end
  end

  defp write_file(content, file) do
    File.write!(file, content)
  end
end
