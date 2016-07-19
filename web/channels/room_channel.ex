defmodule ChannelChats.RoomChannel do
  use Phoenix.Channel
  # import ChannelChats.Presence, only: [track: 3, list: 1]

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic
  Possible Return Values
  `{:ok, socket}` to authorize subscription for channel for requested topic
  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """

  def join("rooms:" <> _room, message, socket) do
    Process.flag(:trap_exit, true)
    send(self, {:after_join, message})

    {:ok, socket}
  end

  def handle_info({:after_join, msg}, socket) do
    user = %{id: msg["user"]}
    # {:ok, _} = track(socket, user[:id], user)

    push socket, "presences", %{presences: []}#list(socket.topic)}
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "new:msg", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def terminate(_reason, _socket) do
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast! socket, "new:msg", %{user: msg["user"], body: msg["body"]}
    ChatLog.log_message(socket.topic, %{user: msg["user"], body: msg["body"]})
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end
end
