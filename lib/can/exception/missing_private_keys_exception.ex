defmodule Can.Exception.MissingPrivateKeys do
  defexception plug_status: 500, message: "you tried to use " <>
    "Can but it requires the phoenix controller pipeline " <>
    "to assign the private `:phoenix_controller` and `:phoenix_action` " <>
    "keys and values to the connection", key: nil


  def exception(opts) do
    key = Keyword.fetch!(opts, :key)
    %Can.Exception.MissingPrivateKeys
    {
      message: "you tried to " <>
        "use Can module but it requires phoenix controller " <>
        "pipeline to assign the `#{key}` key and value to the connection.",
      key: key
    }
  end
end
