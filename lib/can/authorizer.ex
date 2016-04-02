defmodule Can.Authorizer do
  import Can.Helper
  import Plug.Conn, only: [put_private: 3]
  require IEx

  def authorize(conn, args) when is_list(args), do: authorize(conn, nil, args)
  def authorize(conn, resource) when is_map(resource), do: authorize(conn, nil, resource)

  def authorize(conn, action \\ nil, args \\ [])
  @doc """
  Used with a changeset
  """
  def authorize(conn, action, %Ecto.Changeset{} = changeset) do
    action = action || fetch_private!(conn, :phoenix_action)
    trusted =
      changeset.model.__struct__
      |> policy_module
      |> apply_policy(action, [conn, changeset])

    if trusted do
      put_private(conn, :can_authorized, true)
    else
      conn
    end
  end
  @doc """
  Used without a resource
  """
  def authorize(conn, action, args) when is_list(args) do
    action = action || fetch_private!(conn, :phoenix_action)
    trusted =
      conn
      |> fetch_private!(:phoenix_controller)
      |> policy_module("Controller")
      |> apply_policy(action, [conn] ++ args)

    if trusted do
      put_private(conn, :can_authorized, true)
    else
      conn
    end
  end
  @doc """
  Used with a model
  """
  def authorize(conn, action, model) when is_map(model) do
    action = action || fetch_private!(conn, :phoenix_action)
    trusted =
      model.__struct__
      |> policy_module
      |> apply_policy(action, [conn, model])

    if trusted do
      put_private(conn, :can_authorized, true)
    else
      conn
    end
  end
end
