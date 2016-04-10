# Can
> Dead simple, fire and forget authorization kit for the Phoenix framework

[![Build Status](https://semaphoreci.com/api/v1/imranismail/can/branches/master/badge.svg)](https://semaphoreci.com/imranismail/can)
[![Hex Downloads](https://img.shields.io/hexpm/dt/can.svg)](https://hex.pm/packages/can)
[![Hex Version](https://img.shields.io/hexpm/v/can.svg)](https://hex.pm/packages/can)

## Installation
Add Can to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:can, "~>0.0.4"}]
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

#### Step 1

Use the can macro and add an unauthorized_handler

```elixir
defmodule MyApp.PageController do
  use MyApp.Web, :controller
  use Can, :unauthorized

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

#### Step 2

Add the policy module and function

Can will try to find the policy based on the second argument and the following pattern, therefore we need to adhere
to a convention set by Phoenix

- if no argument or `nil` is passed -> the policy will be based off the controller's name
- if changeset or model struct is passed -> the policy will be based off the model's name

```elixir
def MyApp.PagePolicy do
  def show(conn, page) do
    conn.assign.current_user.id == page[:author_id]
  end
end
```

### Alternative Handler

The unauthorized handler can also be done in a separate module if you wish so.

This effectively separates the handler and the controller, and makes pattern matching against the policy clean, readable and reusable.

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
