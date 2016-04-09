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

Step 1. Use Can and the add the handler in your controller
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

  defp unauthorized_handler(conn, page, policy) do
    conn
    |> put_flash(:error, "You are unauthorized because #{policy} did not return true for #{page.id}")
    |> render("show.html", page: page)
  end
end
```

Step 2. Define your policy by mirroring your controller and it's action
```elixir
def MyApp.PagePolicy do
  def show(conn, page) do
    conn.assign.current_user.id == page[:author_id]
  end
end
```

You can write your own authorization logic as complex or as simple as you wish. It is necessary however, at the end of your authorization logic, it has to return a boolean value.

In the case when the authorization logic returns true, the connection proceeds normally. If the authorization logic return false, the unauthorized handler will be called instead.

## Documentation
See [documentation](http://hexdocs.pm/can/) on hexdocs for API reference and usage details.
