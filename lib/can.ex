defmodule Can do
  defmacro __using__(opts) do
    quote do
      import Can.Authorizer
      import Can

      @can_handler unquote(opts[:handler]) || raise Can.NoHandlerError
      @can_module  unquote(opts[:module])  || __MODULE__

      def action(conn, _) do
        try do
          args = [conn, conn.params]
          apply(__MODULE__, action_name(conn), args)
        rescue
          error in Can.UnauthorizedError ->
            opts = Map.from_struct(error)
            args = [conn, opts]
            apply(@can_module, @can_handler, args)
        end
      end

      defoverridable action: 2
    end
  end

  defmacro can(conn, action, resource \\ nil, opts \\ []) do
    quote do
      conn     = unquote(conn)
      action   = unquote(action)
      resource = unquote(resource)
      opts     = unquote(opts)

      case authorize(conn, action, resource) do
        :ok              ->
          conn
        {:error, policy} ->
          opts = opts ++ [resource: resource, policy: policy]
          raise Can.UnauthorizedError, opts
      end
    end
  end
end
