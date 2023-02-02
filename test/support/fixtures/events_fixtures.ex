defmodule Dora.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dora.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{})
      |> Dora.Events.create_event()

    event
  end
end
