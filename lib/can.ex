defmodule Can do
  import Can.Helper
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    action = fetch_private!(conn, :phoenix_action)
    policy = conn
    |> fetch_private!(:phoenix_controller)
    |> policy_module("Controller")

    conn
    |> put_private(:can_policy, policy)
    |> put_private(:can_action, action)
  end

  def set_policy(conn, policy) do
    put_private(conn, :can_policy, policy)
  end

  def can(conn, action \\ nil, resource \\ nil, context \\ []) do
    policy     = fetch_private!(conn, :can_policy)
    action     = action || fetch_private!(conn, :can_action)
    authorized = apply_policy(policy, action, [conn, resource])

    if authorized do
      conn
    else
      context = context ++ [resource: resource, policy: policy]
      raise Can.UnauthorizedError, context: context
    end
  end

  defmacro __using__(opts) do
    quote do
      import Can

      plug Can

      def action(conn, _) do
        handler = unquote(opts[:handler]) || raise Can.NoHandlerError
        module  = unquote(opts[:module])  || __MODULE__

        try do
          args = [conn, conn.params]
          apply(__MODULE__, action_name(conn), args)
        rescue
          error in Can.UnauthorizedError ->
            context = error
            |> Map.fetch!(:context)
            |> Enum.into(%{})
            args    = [conn, context]
            apply(module, handler, args)
        end
      end

      defoverridable action: 2
    end
  end
end
