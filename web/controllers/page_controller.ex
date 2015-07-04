defmodule ChannelChats.PageController do
  use ChannelChats.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
