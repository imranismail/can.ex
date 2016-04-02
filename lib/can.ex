defmodule Can do
  def controller do
    quote do
      import Can.Authorizer
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
