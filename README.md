# Can
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
Generally, there are two things you need to explicitly implement in your application.

1. AuthorizationPolicy
2. UnauthorizedHandler

Step 1. Add Can.AuthorizeConnection plug to your Router pipeline
```elixir
defmodule MyApp.Router do
  use MyApp.Web, :router

  pipeline :authorize do
    plug Can.AuthorizeConnection, handler: MyApp.UnauthorizedHandler
  end

  scope "/", MyApp do
    pipe_through :authorize

    get "/", PageController, :show
  end
end
```

Step 2. Add use Can, :controller to your controller
```elixir
defmodule MyApp.PageController do
  use MyApp.Web, :controller
  use Can, :controller

  def show(conn, %{"id" => id}) do
    page = Repo.get(Page, id)
    conn
    |> authorize(page)

    render(conn, "show.html", page: page)
  end
end
```

Step 3. Define your policy by mirroring your controller and it's action
```elixir
def MyApp.UserPolicy do
  def show(conn, page) do
    if conn.assign.current_user == page[:author], do: true
  end
end
```

You can write your own authorization logic as complex or as simple as you wish. It is necessary however, at the end of your authorization logic, it has to return a boolean value.

In the case when the authorization logic returns true, the connection proceeds normally. If the authorization logic return false, UnauthorizedHandler will handle the connection.

Step 4. Define your own UnauthorizedHandler, by default it is defined as the following
```elixir
defmodule Aleuto.UnauthorizedHandler do
  def handler(conn, UserPolicy) do
    conn
    |> send_resp(401, "Unauthorized")
  end
end
```

## Documentation
See [documentation](http://hexdocs.pm/can/) on hexdocs for API reference and usage details.
