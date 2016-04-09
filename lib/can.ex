defmodule Can do
  defmacro __using__(handler) do
    quote do
      import Can.Authorizer
      import Can
      @unauthorized_handler unquote(handler)
    end
  end

  defmacro can(conn, resource \\ nil, do: block) do
    quote do
      case authorize(unquote(conn), unquote(resource)) do
        {:ok, policy} ->
          unquote(block)
        {:error, policy} ->
          case @unauthorized_handler do
            {module_name, function_name} ->
              apply(module_name, function_name, [unquote(conn), unquote(resource), policy])
            function_name ->
              apply(__MODULE__, function_name, [unquote(conn), unquote(resource), policy])
          end
      end
    end
  end
end
