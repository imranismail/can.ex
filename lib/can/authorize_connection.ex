defmodule Can.AuthorizeConnection do
  import Plug.Conn, only: [put_private: 3, register_before_send: 2]

  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> put_private(:can_authorized, nil)
    |> register_before_send(fn conn -> apply(opts[:handler], :handler, [conn, conn.private[:can_policy]]) end)
  end
end