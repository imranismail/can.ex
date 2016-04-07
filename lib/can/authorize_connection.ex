defmodule Can.AuthorizeConnection do
  import Plug.Conn, only: [put_private: 3]

  def init(opts), do: opts

  def call(conn, opts) do
    conn
      |> put_private(:can_authorized, false)
      |> put_private(:registered_callbacks, opts[:handler]) # should add into a List instead?
      |> IO.inspect
  end
end