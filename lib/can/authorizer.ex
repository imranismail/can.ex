defmodule Can.Authorizer do
  import Can.Helper

  @doc """
  Authorize headers
  """
  def authorize(conn, args) when is_list(args), do: authorize(conn, nil, args)
  def authorize(conn, resource) when is_map(resource), do: authorize(conn, nil, resource)
  def authorize(conn, action \\ nil, args \\ [])

  @doc """
  Used with a changeset
  """
  def authorize(conn, action, %Ecto.Changeset{} = changeset) do
    action = action || fetch_private!(conn, :phoenix_action)
    policy = policy_module(changeset.model.__struct__)
    authorized = apply_policy(policy, action, [conn, changeset])
    if authorized, do: {:ok, policy}, else: {:error, policy}
  end

  @doc """
  Used without a resource
  """
  def authorize(conn, action, args) when is_list(args) do
    action = action || fetch_private!(conn, :phoenix_action)
    policy = conn
      |> fetch_private!(:phoenix_controller)
      |> policy_module("Controller")
    authorized = apply_policy(policy, action, [conn] ++ args)
    if authorized, do: {:ok, policy}, else: {:error, policy}
  end

  @doc """
  Used with a model
  """
  def authorize(conn, action, model) when is_map(model) do
    action = action || fetch_private!(conn, :phoenix_action)
    policy = policy_module(model.__struct__)
    authorized = apply_policy(policy, action, [conn, model])
    if authorized, do: {:ok, policy}, else: {:error, policy}
  end
end
