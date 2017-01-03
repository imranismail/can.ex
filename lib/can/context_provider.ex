defmodule Can.ContextProvider do
  use Plug.Builder

  def call(conn, _opts) do
    action = fetch_action!(conn)
    policy = fetch_module!(conn)
    can    = struct(Can, action: action, policy: policy)
    put_private(conn, :can, can)
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
