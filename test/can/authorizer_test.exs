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
    authorize_conn = default_conn
      |> App.UserController.show

    assert authorize_conn.private[:can_authorized] == true

    authorize_conn_with_action = default_conn
      |> App.UserController.show(nil, :edit)

    assert authorize_conn_with_action.private[:can_authorized] == false
    assert authorize_conn_with_action.private[:can_policy] == App.UserPolicy
  end

  test "#authorize with a model", %{default_conn: default_conn} do
    model_conn = default_conn
      |> App.UserController.show(%App.User{})

    assert model_conn.private[:can_authorized] == true

    model_conn_with_action = default_conn
      |> App.UserController.show(%App.User{}, :edit)

    assert model_conn_with_action.private[:can_authorized] == false
    assert model_conn_with_action.private[:can_policy] == App.UserPolicy
  end

  test "#authorize with a changeset", %{default_conn: default_conn} do
    changeset_conn = default_conn
      |> App.UserController.show(App.User.changeset(%App.User{}))

    assert changeset_conn.private[:can_authorized] == true

    changeset_conn_with_action = default_conn
      |> App.UserController.show(App.User.changeset(%App.User{}), :edit)

    assert changeset_conn_with_action.private[:can_authorized] == false
    assert changeset_conn_with_action.private[:can_policy] == App.UserPolicy
  end
end
