defmodule Dora.Settings do
  import Ecto.Query, warn: false
  alias Dora.Repo

  alias Dora.Settings.Setting

  def get_or_create_setting() do
    case get_setting() do
      nil ->
        {:ok, setting} = create_setting()
        setting

      setting ->
        setting
    end
  end

  def update_setting(attrs) do
    setting = get_or_create_setting()

    setting
    |> Setting.changeset(attrs)
    |> Repo.update()
  end

  defp get_setting do
    case Repo.all(Setting) do
      [] ->
        nil

      list ->
        hd(list)
    end
  end

  defp create_setting(attrs \\ %{}) do
    %Setting{}
    |> Setting.changeset(attrs)
    |> Repo.insert()
  end
end
