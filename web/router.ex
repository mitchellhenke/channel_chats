defmodule ChannelChats.Router do
  use ChannelChats.Web, :router

  socket "/ws", ChannelChats do
    channel "rooms:*", RoomChannel
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
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
