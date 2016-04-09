defmodule Can.AuthorizerTest do
  use ExUnit.Case
  use Plug.Test
  require IEx

  doctest Can.Authorizer

  defmodule App do
    defmodule UserPolicy do
      def show(_conn, _user \\ nil) do
        true
      end

      def edit(_conn, _user \\ nil) do
        false
      end
    end

    defmodule User do
      use Ecto.Schema
      import Ecto.Changeset

      schema "users" do
        field :name, :string
      end

      @required_fields ~w(name)
      @optional_fields ~w()

      def changeset(model, params \\ :empty) do
        model
        |> cast(params, @required_fields, @optional_fields)
      end
    end

    defmodule UserController do
      use Can, :controller

      # plug Can.AuthorizeConnection, handler: App.UnauthorizedHandler

      def show(conn, context \\ nil, action \\ nil) do
        if context == nil do
          authorize(conn, action)
        else
          authorize(conn, action, context)
        end
      end
    end
  end

  setup do
    default_conn = conn(:get, "/")
      |> put_private(:phoenix_action, :show)
      |> put_private(:phoenix_controller, App.UserController)

    {:ok, [default_conn: default_conn]}
  end

  test "raises when phoenix private fields are absent" do
    conn = conn(:get, "/")

    assert_raise Can.Exception.MissingPrivateKeys, fn ->
      App.UserController.show(conn, %{"user" => %{ "id" => 1 }})
    end
  end

  test "#authorize", %{default_conn: default_conn} do
    assert {:ok, policy} = App.UserController.show(default_conn)
    assert policy == Can.AuthorizerTest.App.UserPolicy
    assert {:error, policy} = App.UserController.show(default_conn, nil, :edit)
    assert policy == Can.AuthorizerTest.App.UserPolicy
  end

  test "#authorize with a model", %{default_conn: default_conn} do
    assert {:ok, policy} = App.UserController.show(default_conn, %App.User{})
    assert policy == Can.AuthorizerTest.App.UserPolicy
    assert {:error, policy} = App.UserController.show(default_conn, %App.User{}, :edit)
    assert policy == Can.AuthorizerTest.App.UserPolicy
  end

  test "#authorize with a changeset", %{default_conn: default_conn} do
    assert {:ok, policy} = App.UserController.show(default_conn, App.User.changeset(%App.User{}))
    assert policy == Can.AuthorizerTest.App.UserPolicy
    assert {:error, policy} = App.UserController.show(default_conn, App.User.changeset(%App.User{}), :edit)
    assert policy == Can.AuthorizerTest.App.UserPolicy
  end
end
