defmodule Snaktrip.Web.RealtimeServer do

  @moduledoc """
    Testing this module.
    {_, {_, rpid}} = Web.RealtimeServer.start_link
    Web.RealtimeServer.send_updates(:uploads, rpid, "Test Message ")
    Web.RealtimeServer.send_updates(:uploads, rpid, "not supposed to happen but it happening")
  """
  use GenServer

  require Record
  Record.defrecord :state, [clients: []]

  # Implement the server interface

  def start_link(opts \\ []) do
    :gen_server.start_link({:local, __MODULE__}, __MODULE__, :ok, opts)
  end

  def join(pid) do
    :gen_server.cast(__MODULE__, {:join, pid})
  end

  def leave(pid) do
    :gen_server.cast(__MODULE__, {:leave, pid})
  end

  def send_messages(:others, pid, message) do
    :gen_server.cast(__MODULE__, {:send_message, pid, message})
  end

  def send_updates(:uploads, pid, message) do
    :gen_server.cast(__MODULE__, {:upload_message, pid, message } )
  end

  # Server implemenation

  @doc """
    states :: Erlang Record
    Initializes with state( clients connected )
  """
  def init(:ok) do
    state = state()
    {:ok, state}
  end

  @doc """
    Handles when a new client pid joins.
  """
  def handle_cast({:join, pid}, state) do
    {:noreply, add_client(state, pid) }
  end

  def handle_cast({:leave, pid}, state) do
    {:noreply, remove_client(state, pid)}
  end

  def handle_cast({:send_message, pid, message}, state) do
    send_message(:others, pid, message, state)
    {:noreply, state}
  end

  def handle_cast({:upload_message, pid, message }, state) do
    send_upload_update_message(:all, pid, message, state )
    {:noreply, state}
  end

  def handle_cast({:notify_all, pid, message}, state) do
    send_message(:all, pid, message, state)
    {:noreply, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  def terminate(_reason, _state), do: :ok

  # End of callback_functions.

  defp add_client(state, pid) do
    state(clients: [ pid | state(state, :clients)] )
  end

  defp remove_client(state, pid) do
    minused = state(state, :clients) -- [pid]
    state(clients: minused)
  end

  defp send_message(:others, pid, message, state) do
    clients = state(state, :clients)
    others = clients -- [pid]
    Enum.each(others, &(send(&1, {:send_message, self(), message} )))
  end

  defp send_message(:all, _pid, message, state) do
    clients = state(state, :clients)
    Enum.each(clients, &(send(&1, { :send_message, self(), message } )))
  end

  defp send_upload_update_message(:all, _pid, message, state) do
    clients = state(state, :clients)
    Enum.each(clients, &(send(&1, {:upload_update_message, self(), message } )))
  end

end
