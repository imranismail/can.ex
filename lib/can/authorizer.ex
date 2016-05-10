defmodule Can.Authorizer do
  import Can.Helper

  @doc """
  Used without a resource
  """
  def authorize(conn, action, resource) do
    policy     = conn
    |> fetch_private!(:phoenix_controller)
    |> policy_module("Controller")
    action     = action || fetch_private!(conn, :phoenix_action)
    authorized = apply_policy(policy, action, [conn, resource])

    if authorized, do: :ok, else: {:error, policy}
  end
end
