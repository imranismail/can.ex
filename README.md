# Can
> Dead simple, fire and forget authorization kit for the Phoenix framework

[![Build Status](https://semaphoreci.com/api/v1/imranismail/can/branches/master/badge.svg)](https://semaphoreci.com/imranismail/can)

## Installation
Add Can to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:can, "~>0.0.2"}]
end
```

## Usage
Generally, there are two things you need to explicitly implement in your application.

For this controller and action

```elixir
defmodule MyApp.PageController do
  def show(conn, %{"id" => id}) do
    page = Repo.get(Page, id)
    render(conn, "show.html", page: page)
  end
end
```

1. You will first need to define your policy by mirroring your controller naming convention and it's action

```elixir
def MyApp.PagePolicy do
  def show(conn, page) do
    conn.assign.current_user.id == page[:author_id]
  end
end
```

2. Use the can macro and add an unauthorized_handler

```elixir
defmodule MyApp.PageController do
  use MyApp.Web, :controller
  use Can, :unauthorized_handler

  def show(conn, %{"id" => id}) do
    page = Repo.get(Page, id)

    can(conn, page) do
      render(conn, "show.html", page: page)
    end
  end

  def unauthorized(conn, resource, policy) do
    conn
    |> put_flash(:error, "You are unauthorized because #{policy} did not return true for author id #{resource[:author_id]}")
    |> render("show.html", page: resource)
  end
end
```

### Alternative Handler

The unauthorized handler can also be done in a separate module if you wish so.

This effectively separates the handler and the controller, and makes pattern matching against the policy clean and readable

```elixir
defmodule MyApp.PageController do
  use MyApp.Web, :controller
  use Can, {MyApp.UnauthorizedHandler, :unauthorized}

  def show(conn, %{"id" => id}) do
    page = Repo.get(Page, id)

    can(conn, page) do
      render(conn, "show.html", page: page)
    end
  end
end

defmodule MyApp.UnauthorizedHandler do
  import Phoenix.Controller

  def unauthorized(conn, resource, PagePolicy) do
    conn
    |> put_flash(:error, "You are unauthorized because #{policy} did not return true for author id #{resource[:author_id]}")
    |> render("show.html", page: resource)
  end

  # wildcard
  def unauthorized(conn, _resource, policy) do
    conn
    |> put_flash(:error, "You are unauthorized because #{policy} did not return true")
    |> render(MyApp.ErrorView, "401.html")
  end
end
```

You can write your own authorization logic as complex or as simple as you wish. It is necessary however, at the end of your authorization logic, it has to return a boolean value.

In the case when the authorization logic returns true, the connection proceeds normally. If the authorization logic return false, the unauthorized handler will be called instead.

## Documentation
See [documentation](http://hexdocs.pm/can/) on hexdocs for API reference and usage details.
