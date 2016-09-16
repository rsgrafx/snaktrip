defmodule Snaktrip.User.Manager do
  use GenServer
  @moduledoc """
    Represents the Caching Systeml for the - user pids

  """
  # Returns Pid - for Snaktrip.User.Server

  def fetch(by_email) do
    GenServer.call(:snak_user_manager, {:server_process, by_email})
  end

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :snak_user_manager)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:server_process, email}, _, state) do
    do_handle_call(state, email)
  end

  def do_handle_call(user_servers, email) do
    case Map.fetch(user_servers, email) do
      {:ok, pid} ->
        {:reply, pid, user_servers}
      :error ->
        {:ok, pid} = Snaktrip.User.Server.start_link(%{"email" => email})
        {:reply, pid, Map.put(user_servers, email, pid)}
    end
  end

end
