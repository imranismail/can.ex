defmodule Can do
  defstruct [
    policy: nil,
    action: nil,
    authorized?: false
  ]

  use Plug.Builder

  def call(conn, _opts) do
    action = fetch_action!(conn)
    policy = fetch_module!(conn)
    can    = struct(__MODULE__, action: action, policy: policy)
    put_private(conn, :can, can)
  end

  def can(conn, policy \\ nil, action \\ nil, context \\ []) when is_list(context) do
    policy      = get_policy(conn, policy)
    action      = get_action(conn, action)
    context     = [conn, Enum.into(context, %{})]
    authorized? = apply_policy!(policy, action, context)

    if authorized?, do: authorize(conn), else: conn
  end

  def can!(conn, policy \\ nil, action \\ nil, context \\ []) when is_list(context) do
    conn = can(conn, policy, action, context)

    if authorized?(conn) do
      conn
    else
      raise Can.UnauthorizedError, context: context
    end
  end

  def can?(conn, policy \\ nil, action \\ nil, context \\ []) do
    if authorized?(conn) do
      true
    else
      conn
      |> can(policy, action, context)
      |> authorized?()
    end
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

  def get_policy(conn, policy) do
    conn.private[:can].policy || policy
  end

  def put_action(conn, action) do
    put_can(conn, :action, action)
  end

  def get_action(conn, action) do
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

  defp fetch_action!(conn) do
    Map.fetch!(conn.private, :phoenix_action)
  end

  defp fetch_module!(conn) do
    conn.private
    |> Map.fetch!(:phoenix_controller)
    |> infer_policy("Controller")
  end

  defp infer_policy(module, suffix) do
    module_parts = Module.split(module)

    policy =
      module_parts
      |> List.last
      |> unsuffix(suffix)
      |> suffix("Policy")

    module_parts
    |> List.replace_at(length(module_parts) - 1, policy)
    |> Module.concat
  end

  defp suffix(prefix, suffix) do
    prefix <> suffix
  end

  defp unsuffix(value, suffix) do
    string = to_string(value)
    suffix_size = byte_size(suffix)
    prefix_size = byte_size(string) - suffix_size
    case string do
      <<prefix::binary-size(prefix_size), ^suffix::binary>> -> prefix
      _ -> string
    end
  end
end
