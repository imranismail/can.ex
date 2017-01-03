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

### Inferring policy from controller name and action

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

# in post_controller.ex
defmodule MyApp.PostController do
  use MyApp.Web, :controller

  def show(conn, %{"id" => id}) do
    post = Repo.get(Post, id)

    conn
    |> can!(post: post)
    |> render("show.html", post: post)
  end
end

# in post_policy.ex
defmodule MyApp.PostPolicy do
  def show(conn, context) do
    context[:post].author_id == Auth.current(conn).id
  end
end

# in error_view.ex
defmodule MyApp.ErrorView do
  use MyApp.Web, :view

  # ...other definitions
  def render("401.html", %{reason: %{context: %{post: post}}}) do
    "You are not authorized to view #{post.id}"
  end
end
```

### Overriding inferred policy or action with plug

```elixir
# in post_controller.ex
defmodule MyApp.PostController do
  use MyApp.Web, :controller

  plug Can.ContextProvider, policy: __MODULE__, action: :show_post

  def show(conn, %{"id" => id}) do
    post = Repo.get(Post, id)

    conn
    |> can!(post: post)
    |> render("show.html", post: post)
  end

  def show_post(conn, context) do
    context[:post].author_id == Auth.current(conn).id
  end
end
```

### Overriding inferred policy or action with `%Conn{}` transformation

```elixir
# in post_controller.ex
defmodule MyApp.PostController do
  use MyApp.Web, :controller

  def show(conn, %{"id" => id}) do
    post = Repo.get(Post, id)

    conn
    |> put_policy(__MODULE__)
    |> can!(:show_post, post: post)
    |> render("show.html", post: post)
  end

  def show_post(conn, context) do
    context[:post].author_id == Auth.current(conn).id
  end
end
```

```elixir
# in post_controller.ex
defmodule MyApp.PostController do
  use MyApp.Web, :controller

  def show(conn, %{"id" => id}) do
    post = Repo.get(Post, id)

    conn
    |> put_policy(__MODULE__)
    |> put_action(:show_post)
    |> can!(post: post)
    |> render("show.html", post: post)
  end

  def show_post(conn, context) do
    context[:post].author_id == Auth.current(conn).id
  end
end
```

### Usage in views

```elixir
# in web.ex
defmodule MyApp.Web do
  def view() do
    quote do
      # ...other definitions
      import Can
    end
  end
end

# in layout.html.slim
.nav_menu
  = if can?(@conn, :index) do
    = link_to("POSTS", post_path(@conn, :index))
  = if can?(@conn, :superadmin?) do
    = link_to("SETTINGS", setting_path(@conn, :index))
```
