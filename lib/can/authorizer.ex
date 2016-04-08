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
    policy =
      changeset.model.__struct__
      |> policy_module

    trusted = apply_policy(policy, action, [conn, changeset])

    if trusted do
      conn
      |> put_private(:can_authorized, true)
    else
      conn
      |> put_private(:can_authorized, false)
      |> put_private(:can_policy, policy)
    end
  end
  @doc """
  Used without a resource
  """
  def authorize(conn, action, args) when is_list(args) do
    action = action || fetch_private!(conn, :phoenix_action)
    policy = conn
      |> fetch_private!(:phoenix_controller)
      |> policy_module("Controller")

    trusted = apply_policy(policy, action, [conn] ++ args)

    if trusted do
      conn
      |> put_private(:can_authorized, true)
    else
      conn
      |> put_private(:can_authorized, false)
      |> put_private(:can_policy, policy)
    end
  end
  @doc """
  Used with a model
  """
  def authorize(conn, action, model) when is_map(model) do
    action = action || fetch_private!(conn, :phoenix_action)
    policy =
      model.__struct__
      |> policy_module

    trusted = apply_policy(policy, action, [conn, model])

    if trusted do
      conn
      |> put_private(:can_authorized, true)
    else
      conn
      |> put_private(:can_authorized, false)
      |> put_private(:can_policy, policy)
    end
  end
end
