[![Stories in Ready](https://badge.waffle.io/127labs/can.png?label=ready&title=Ready)](https://waffle.io/127labs/can)
# Can
> Dead simple, fire and forget authorization kit for the Phoenix framework

[![Build Status](https://semaphoreci.com/api/v1/imranismail/can/branches/master/badge.svg)](https://semaphoreci.com/imranismail/can)
[![Hex Downloads](https://img.shields.io/hexpm/dt/can.svg)](https://hex.pm/packages/can)
[![Hex Version](https://img.shields.io/hexpm/v/can.svg)](https://hex.pm/packages/can)

## Installation
Add Can to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:can, "~>0.0.5"}]
end
```

## Usage

```elixir
# in web.ex
defmodule MyApp.Web do
  def controller() do
    quote do
      # ...other definitions
      import Can

      plug Can.ContextProvider
    end
  end
end

# in page_controller.ex
defmodule MyApp.PageController do
  use MyApp.Web, :controller

  def show(conn, %{"id" => id}) do
    page = Repo.get(Page, id)

    conn
    |> can(page: page)
    |> render("show.html", page: page)
  end
end

# in error_view.ex
defmodule MyApp.ErrorView do
  use MyApp.Web, :view

  # ...other definitions
  def render("401.html", assigns) do
    "Internal server error"
  end
end
```
