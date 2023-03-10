defmodule Dora.SettingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dora.Settings` context.
  """

  @doc """
  Generate a setting.
  """
  def setting_fixture(attrs \\ %{}) do
    {:ok, setting} =
      attrs
      |> Enum.into(%{
        protected_api: true
      })
      |> Dora.Settings.create_setting()

    setting
  end
end
