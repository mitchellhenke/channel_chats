defmodule ChannelChats.Router do
  use ChannelChats.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :put_secure_browser_headers
  end

  scope "/", ChannelChats do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChannelChats do
  #   pipe_through :api
  # end
end
