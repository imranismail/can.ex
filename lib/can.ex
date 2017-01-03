defmodule Can do
  import Plug.Conn

  defstruct [
    policy: nil,
    action: nil,
    authorized?: false
  ]

  def can(conn, policy, action, context) do
    action = action || get_action(conn)
    policy = policy || get_policy(conn)

    conn =
      conn
      |> put_action(action)
      |> put_policy(policy)

    context = [conn, Enum.into(context, %{})]

    authorized? = apply_policy!(policy, action, context)

    if authorized?, do: authorize(conn), else: conn
  end

  def can(conn, action, context) when is_atom(action) and is_list(context) do
    can(conn, get_policy(conn), action, context)
  end

  def can(conn, action) when is_atom(action) do
    can(conn, get_policy(conn), action, [])
  end

  def can(conn, context) when is_list(context) do
    can(conn, get_policy(conn), get_action(conn), context)
  end

  def can(conn) do
    can(conn, get_policy(conn), get_action(conn), [])
  end

  def can!(conn, policy, action, context) when is_atom(action) and is_list(context) do
    conn = can(conn, policy, action, context)

    if authorized?(conn) do
      conn
    else
      raise Can.UnauthorizedError, context: context
    end
  end

  def can!(conn, action, context) when is_atom(action) and is_list(context) do
    can!(conn, get_policy(conn), action, context)
  end

  def can!(conn, action) when is_atom(action) do
    can!(conn, get_policy(conn), action, [])
  end

  def can!(conn, context) when is_list(context) do
    can!(conn, get_policy(conn), get_action(conn), context)
  end

  def can!(conn) do
    can!(conn, get_policy(conn), get_action(conn), [])
  end

  def can?(conn, policy, action, context) when is_atom(action) and is_list(context) do
    if authorized?(conn) do
      true
    else
      conn
      |> can(policy, action, context)
      |> authorized?()
    end
  end

  def can?(conn, action, context) when is_atom(action) and is_list(context) do
    can?(conn, get_policy(conn), action, context)
  end

  def can?(conn, action) when is_atom(action) do
    can?(conn, get_policy(conn), action, [])
  end

  def can?(conn, context) when is_list(context) do
    can?(conn, get_policy(conn), get_action(conn), context)
  end

  def can?(conn) do
    can?(conn, get_policy(conn), get_action(conn), [])
  end

  def authorize(conn, boolean \\ true) do
    put_can(conn, :authorized?, boolean)
  end

  def authorized?(conn) do
    conn.private[:can].authorized?
  end

  def put_policy(conn, policy) do
    put_can(conn, :policy, policy)
  end

  def get_policy(conn, policy \\ nil) do
    conn.private[:can].policy || policy
  end

  def put_action(conn, action) do
    put_can(conn, :action, action)
  end

  def get_action(conn, action \\ nil) do
    conn.private[:can].action || action
  end

  defp put_can(conn, key, value) do
    can =
      conn.private
      |> Map.get(:can, %Can{})
      |> Map.put(key, value)

    put_private(conn, :can, can)
  end

  defp apply_policy!(policy, function, args) do
    policy
    |> verify_policy!
    |> apply(function, args)
  end

  defp verify_policy!(policy) do
    if Code.ensure_loaded?(policy) do
      policy
    else
      raise Can.UndefinedPolicyError, policy: policy
    end
  end
end
