defmodule Can.UndefinedPolicyError do
  defexception [
    plug_status: 500,
    message: "Undefined policy",
    policy: nil
  ]

  def exception(opts) do
    policy = Keyword.fetch!(opts, :policy)
    struct(__MODULE__, message: "Undefined policy: #{prettify_module(policy)}", policy: policy)
  end

  defp prettify_module(module) do
    module
    |> Module.split()
    |> Enum.join(".")
  end
end

defmodule Can.UnauthorizedError do
  defexception [
    plug_status: 401,
    message: "This connection is not authorized to perform this action",
    action: nil,
    context: nil
  ]
end
