defmodule Can.MissingPrivateKeysError do
  defexception [:message, :key, plug_status: 500]

  def exception(opts) do
    key     = Keyword.fetch!(opts, :key)
    message = Keyword.get(opts, :message) ||
      "you tried to use Can but it requires the key `#{key}` " <>
      "to be assigned in the connection struct"

    %Can.MissingPrivateKeysError{message: message, key: key}
  end
end

defmodule Can.UndefinedPolicyError do
  defexception [:message, :policy, plug_status: 500]

  def exception(opts) do
    policy  = opts
    |> Keyword.fetch!(:policy)
    |> Module.split
    |> Enum.join(".")
    message = Keyword.get(opts, :message) || "undefined policy: #{policy}."

    %Can.UndefinedPolicyError{message: message, policy: policy}
  end
end

defmodule Can.NoHandlerError do
  defexception [:message, plug_status: 500]

  def exception(opts) do
    message = Keyword.get(opts, :message) ||
      "you tried to use Can but it requires the :handler " <>
      "to be specified to be able to handle the unauthorized connections"

    %Can.NoHandlerError{message: message}
  end
end

defmodule Can.PhoenixNotLoadedError do
  defexception [:message, plug_status: 500]

  def exception(opts) do
    message = Keyword.get(opts, :message) ||
      "you tried to use Can but it requires Phoenix to be " <>
      "loaded as a dependency"

    %Can.PhoenixNotLoadedError{message: message}
  end
end

defmodule Can.UnauthorizedError do
  defexception [:context, plug_status: 401, message: "this connection is not " <>
                                                     "authorized to view this resource"]

  def exception(opts) do
    context = Keyword.fetch!(opts, :context)
    %Can.UnauthorizedError{context: context}
  end
end

