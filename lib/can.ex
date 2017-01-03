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

  def can(conn, action \\ nil, context \\ []) when is_atom(action) and is_list(context) do
    policy      = get_policy(conn)
    action      = action || get_action(conn)
    context     = [conn|context]
    authorized? = apply_policy!(policy, action, context)

    if authorized? do
      authorize(conn)
    else
      raise Can.UnauthorizedError, action: action, context: context
    end
  end

  def authorize(conn, boolean \\ true) do
    put_can(conn, :authorized?, boolean)
  end

  def put_policy(conn, policy) do
    put_can(conn, :policy, policy)
  end

  def get_policy(conn) do
    conn.private[:can].policy
  end

  def put_action(conn, action) do
    put_can(conn, :action, action)
  end

  def get_action(conn) do
    conn.private[:can].action
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
