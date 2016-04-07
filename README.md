> Can
> Dead simple, fire and forget authorization kit for the Phoenix framework
[![Build Status](https://semaphoreci.com/api/v1/imranismail/can/branches/master/badge.svg)](https://semaphoreci.com/imranismail/can)

## Installation
Add Can to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:can, "~>0.0.1"}]
end
```

## Usage
When using Can, there are only one thing you need to implement. An authorization policy.
A policy is a simple function that mirrors the controllers' action function.

```elixir
def MyApp.UserController do
  use MyApp.Web, :controller
  use Can, :controller

  def show(conn, params) do
    // make a db query call
    user = Repo.get(Users, params["id"])

    // call Can.authorize/2 function
    authorize(conn, user)

    render "index.html", model: users
  end
end
```

```elixir
def MyApp.UserPolicy do
  def show(conn, user) do
    if conn.assign.user_id == user.id, do: true
  end
end
```

In the policy, you can write your own authorization logic as complex or as simple as you wish.
It is necessary however, at the end of your authorization logic, it has to return either true or false.

In the case when the authorization logic returns true, the connection proceeds normally.
If the authorization logic return false, an Exception is triggered. By default, Can manages an ExceptionHandler internally.
You can override the ExceptionHandler by passing a lambda to the authorize/2 function. (Ithink?)
This gives you the ability to handle unauthorized cases in a more meaningful way, instead of crashing indefinitely.

## How it works
Can works by simply adding authorization key into the `Plug.Conn` map. After evaluating policies, a `:can_authorized` atom of `true` or `false`
are added to the `Plug.Conn` map.

Can then calls `register_before_send/2` callback right before the response is sent to check for the status of `:can_authorized`, given that it is `true`,
the response are sent normally. If it is `false`, an exception is raised.


## Documentation
See [documentation](http://hexdocs.pm/can/) on hexdocs for API reference and usage details.


## WIP: Example
```elixir
defmodule Aleuto.Router do
  use Aleuto.Web, :router

  pipeline :authorize do
    plug Can.AuthorizeConnection, handler: Aleuto.UnauthorizedHandler
  end

  scope "/", Aleuto do
    pipe_through :authorize

    get "/", PageController, :show
  end
end

defmodule Aleuto.PageController do
  use Aleuto.Web, :controller

  def show(conn, %{"id" => id}) do
    page = Repo.get(Page, id)
    conn
    |> authorize(page)

    render(conn, "show.html", page: page)
  end
end

defmodule Aleuto.UnauthorizedHandler do
  defexception plug_status:500, message: "you are unauthorized" <>
  "to access this pipeline"
end
```