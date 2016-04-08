defmodule Can.AuthorizeConnectionTest do
  use ExUnit.Case
  use Plug.Test
  require IEx

  defmodule ExamplePlug do
    use Plug.Builder

    plug Can.AuthorizeConnection, handler: App.UnauthorizedHandler
  end

  setup do
    default_conn = conn(:get, "/")
      |> put_private(:phoenix_action, :show)
      |> put_private(:phoenix_controller, App.UserController)
      |> ExamplePlug.call([])

    {:ok, [default_conn: default_conn]}
  end

  test "initial conn map should have :can_unuthorized set to nil", %{default_conn: default_conn} do
    conn = default_conn
    assert conn.private[:can_authorized] == nil
    assert conn.private[:can_policy] == nil
  end

  test "initial conn map should have a callback registered in the before_send array", %{default_conn: default_conn} do
    conn = default_conn
    assert length(conn.before_send) > 0
    assert conn.before_send |> List.first |> is_function
  end
end

