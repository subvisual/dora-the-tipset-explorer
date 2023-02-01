defmodule DoraWeb.EventProjectionControllerTest do
  use DoraWeb.ConnCase

  import Dora.EventProjectionsFixtures

  alias Dora.EventProjections.EventProjection

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all event_projections", %{conn: conn} do
      conn = get(conn, Routes.event_projection_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create event_projection" do
    test "renders event_projection when data is valid", %{conn: conn} do
      conn = post(conn, Routes.event_projection_path(conn, :create), event_projection: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.event_projection_path(conn, :show, id))

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.event_projection_path(conn, :create), event_projection: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update event_projection" do
    setup [:create_event_projection]

    test "renders event_projection when data is valid", %{conn: conn, event_projection: %EventProjection{id: id} = event_projection} do
      conn = put(conn, Routes.event_projection_path(conn, :update, event_projection), event_projection: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.event_projection_path(conn, :show, id))

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, event_projection: event_projection} do
      conn = put(conn, Routes.event_projection_path(conn, :update, event_projection), event_projection: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete event_projection" do
    setup [:create_event_projection]

    test "deletes chosen event_projection", %{conn: conn, event_projection: event_projection} do
      conn = delete(conn, Routes.event_projection_path(conn, :delete, event_projection))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.event_projection_path(conn, :show, event_projection))
      end
    end
  end

  defp create_event_projection(_) do
    event_projection = event_projection_fixture()
    %{event_projection: event_projection}
  end
end
