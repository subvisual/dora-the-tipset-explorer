defmodule Dora.EventProjectionsTest do
  use Dora.DataCase

  alias Dora.EventProjections

  describe "event_projections" do
    alias Dora.EventProjections.EventProjection

    import Dora.EventProjectionsFixtures

    @invalid_attrs %{}

    test "list_event_projections/0 returns all event_projections" do
      event_projection = event_projection_fixture()
      assert EventProjections.list_event_projections() == [event_projection]
    end

    test "get_event_projection!/1 returns the event_projection with given id" do
      event_projection = event_projection_fixture()
      assert EventProjections.get_event_projection!(event_projection.id) == event_projection
    end

    test "create_event_projection/1 with valid data creates a event_projection" do
      valid_attrs = %{}

      assert {:ok, %EventProjection{} = event_projection} =
               EventProjections.create_event_projection(valid_attrs)
    end

    test "create_event_projection/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               EventProjections.create_event_projection(@invalid_attrs)
    end

    test "update_event_projection/2 with valid data updates the event_projection" do
      event_projection = event_projection_fixture()
      update_attrs = %{}

      assert {:ok, %EventProjection{} = event_projection} =
               EventProjections.update_event_projection(event_projection, update_attrs)
    end

    test "update_event_projection/2 with invalid data returns error changeset" do
      event_projection = event_projection_fixture()

      assert {:error, %Ecto.Changeset{}} =
               EventProjections.update_event_projection(event_projection, @invalid_attrs)

      assert event_projection == EventProjections.get_event_projection!(event_projection.id)
    end

    test "delete_event_projection/1 deletes the event_projection" do
      event_projection = event_projection_fixture()

      assert {:ok, %EventProjection{}} =
               EventProjections.delete_event_projection(event_projection)

      assert_raise Ecto.NoResultsError, fn ->
        EventProjections.get_event_projection!(event_projection.id)
      end
    end

    test "change_event_projection/1 returns a event_projection changeset" do
      event_projection = event_projection_fixture()
      assert %Ecto.Changeset{} = EventProjections.change_event_projection(event_projection)
    end
  end
end
