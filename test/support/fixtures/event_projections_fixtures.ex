defmodule Dora.EventProjectionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dora.EventProjections` context.
  """

  @doc """
  Generate a event_projection.
  """
  def event_projection_fixture(attrs \\ %{}) do
    {:ok, event_projection} =
      attrs
      |> Enum.into(%{

      })
      |> Dora.EventProjections.create_event_projection()

    event_projection
  end
end
