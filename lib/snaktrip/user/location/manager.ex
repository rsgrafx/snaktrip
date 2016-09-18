defmodule Snaktrip.User.Location.Manager do

  use GenServer

  alias Snaktrip.User.Location.Server, as: LocationServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :location_manager)
  end

  def check do
    GenServer.call(:location_manager, {:server_process, :all})
  end

  def fetch(token: token, location: current_location) do
    GenServer.call(:location_manager, {:server_process, {token, current_location}})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:server_process, :all}, _, state) do
    {:reply, state, state}
  end

  def handle_call({:server_process, {token, current_location}}, _, servers) do
    case Map.fetch(servers, token) do
      {:ok, pid} ->
        {:reply, pid, servers}
      :error ->
        {:ok, pid} = LocationServer.start_link( %{token: token, location: current_location} )
        {:reply, pid, Map.put(servers, token, pid)}
    end
  end
end
