defmodule Can do
  defmacro __using__(opts) do
    quote do
      @unauthorized_handler opts[:handler] || raise Can.NoHandlerError
      @unauthorized_module  opts[:module]  || __MODULE__

      import Can.Authorizer
      import Can

      def action(conn, _), do 
        try do
          args = [conn, conn.params]
          apply(__MODULE__, action_name(conn), args)
        rescue
          error in Can.UnauthorizedError ->
            args = [conn, error[:resource], error[:policy]]
            apply(@unauthorized_module, @unauthorized_function, args)
        end
      end

      defoverridable action: 2
    end
  end

  defmacro can(conn, [{action, resource}] \\ nil) do
    quote do
      case authorize(unquote(conn), unquote(action), unquote(resource)) do
        {:ok, _}         -> 
          conn
        {:error, policy} -> 
          raise Can.UnauthorizedError,
            resource: unquote(resource), 
            policy: policy
      end
    end
  end
end
