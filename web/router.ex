defmodule OverHosting.Router do
  use OverHosting.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_user_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OverHosting do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/servers", ServerController
  end

  # Other scopes may use custom stacks.
  # scope "/api", OverHosting do
  #   pipe_through :api
  # end

  defp put_user_token(conn, _) do
    user_id = -1 # Get user id from somewhere?
    token = Phoenix.Token.sign(conn, "user_id", user_id)
    assign(conn, :user_token, token)
  end
end
