defmodule Can.Helper do
  def verify_policy!(policy) do
    if Code.ensure_loaded?(policy) do
      policy
    else
      raise Can.UndefinedPolicyError, policy: policy
    end
  end

  def verify_phoenix_deps! do
    unless Code.ensure_loaded?(Phoenix) do
      raise Can.PhoenixNotLoadedError
    end
  end

  def fetch_private!(conn, key) do
    if !!conn.private[key] do
      conn.private[key]
    else
      raise Can.MissingPrivateKeysError, key: key
    end
  end

  def policy_module(module, suffix \\ "") do
    module_parts = Module.split(module)

    policy = module_parts
    |> List.last
    |> unsuffix(suffix)
    |> suffix("Policy")

    module_parts
    |> List.replace_at(length(module_parts) - 1, policy)
    |> Module.concat
  end

  def apply_policy(policy, function, args) do
    policy
    |> verify_policy!
    |> apply(function, args)
  end

  def suffix(prefix, suffix) do
    prefix <> suffix
  end

  @doc """
  Taken from Phoenix.Naming
  Removes the given suffix from the name if it exists.

  ## Examples

      iex> Can.Helper.unsuffix("MyApp.User", "View")
      "MyApp.User"

      iex> Can.Helper.unsuffix("MyApp.UserView", "View")
      "MyApp.User"

  """
  @spec unsuffix(String.t, String.t) :: String.t
  def unsuffix(value, suffix) do
    string = to_string(value)
    suffix_size = byte_size(suffix)
    prefix_size = byte_size(string) - suffix_size
    case string do
      <<prefix::binary-size(prefix_size), ^suffix::binary>> -> prefix
      _ -> string
    end
  end
end
