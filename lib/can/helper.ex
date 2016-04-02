defmodule Can.Helper do
  import Phoenix.Naming, only: [unsuffix: 2]

  alias Can.Exception

  def verify_policy!(policy) do
    if Code.ensure_loaded?(policy) do
      policy
    else
      raise Exception.UndefinedPolicyError, policy: policy
    end
  end

  def verify_phoenix_deps! do
    unless Code.ensure_loaded?(Phoenix) do
      raise Exception.PhoenixNotLoadedError
    end
  end

  def fetch_private!(conn, key) do
    if !!conn.private[key] do
      conn.private[key]
    else
      raise Exception.MissingPrivateKeys, key: key
    end
  end

  def policy_module(module, suffix \\ "") do
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

  def apply_policy(policy, function, args) do
    policy
    |> verify_policy!
    |> apply(function, args)
  end

  def suffix(prefix, suffix) do
    prefix <> suffix
  end
end
