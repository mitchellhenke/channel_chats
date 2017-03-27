defmodule ChatLog do
  use GenServer

  def start_link(opts \\ []) do
    log_limit = opts[:log_limit] || 100
    {:ok, _pid} = GenServer.start_link(ChatLog, [
      {:ets_table_name, :chat_log_table},
      {:log_limit, log_limit}
    ], opts)
  end

  def get_logs(room) do
    GenServer.call(:chat_log, {room})
  end

  def stop(server) do
    GenServer.call(server, :stop)
  end

  def init(args) do

    [{:ets_table_name, ets_table_name}, {:log_limit, log_limit}] = args

    :ets.new(ets_table_name, [:named_table, :set, :private])

    {:ok, %{log_limit: log_limit, ets_table_name: ets_table_name}}
  end

   def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_call({room, message}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    result = log_message(room, message, ets_table_name, state[:log_limit])
    {:reply, result, state}
  end

  def handle_call({room}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    result = :ets.lookup(ets_table_name, room)
    {:reply, result, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:reply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def code_change(_old_version, state, _extra) do
    {:ok, state}
  end

  def log_message(channel, message) do
    GenServer.call(:chat_log, {channel, message})
  end

  defp log_message(channel, message, ets_table_name, log_limit) do
    case :ets.member(ets_table_name, channel) do
      false ->
        true = :ets.insert(ets_table_name, {channel, [message]})
        {:ok, message}
      true ->
         [{_channel, messages}] = :ets.lookup(ets_table_name, channel)
         :ets.insert(ets_table_name, {channel, Enum.slice([message | messages], 0, log_limit)})
        {:ok, message}
    end
  end
end
