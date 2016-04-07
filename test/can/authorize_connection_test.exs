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

  test "initial conn map should have :can_unuthorized set to false", %{default_conn: default_conn} do
    conn = default_conn
    assert conn.private[:can_authorized] == false
  end

  test "initial conn map should have :registered_callback set to UnauthorizedHandler", %{default_conn: default_conn} do
    conn = default_conn
    assert conn.private[:registered_callbacks]
  end


end

