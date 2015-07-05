defmodule ChannelChats.PageController do
  use ChannelChats.Web, :controller

  def index(conn, _params) do
    messages = ChatLog.get_logs("rooms:lobby")
    |> parse_logs
    render conn, "index.html", messages: messages
  end

  def parse_logs([]), do: []
  def parse_logs([{_room, messages}]), do: Enum.reverse(messages)
end
