defmodule ChannelChats.PageController do
  use ChannelChats.Web, :controller

  def index(conn, params) do
    room_name = params["room"] || "lobby"
    room = "rooms:#{room_name}"
    messages = ChatLog.get_logs(room)
    |> parse_logs
    render conn, "index.html", messages: messages
  end

  def parse_logs([]), do: []
  def parse_logs([{_room, messages}]), do: Enum.reverse(messages)
end
