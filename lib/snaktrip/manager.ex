defmodule Snaktrip.Manager do
  use GenServer
  @moduledoc """
    Represents the Caching system that maps
    -> Snaktrip uuids to GenServer pids that maintain the STATE
    * if no pid exists will generate a new Process
      * pulling last known state from the Repo.
  """

  def start do
    # Will eventually modify to pull in last known state
    # From ETS repo.
    GenServer.start_link(__MODULE__, %{})
  end


  @doc """
    Calls into the Cache - fetches or creates server process which
    maintains the state of individual snaktrip.
  """

  def fetch(manager_pid, snaktrip_uuid) do
    GenServer.call(manager_pid, {:server_process, snaktrip_uuid} )
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:server_process, snaktrip_uuid}, _, snak_servers) do
    case Map.fetch( snak_servers, snaktrip_uuid ) do
      {:ok, server_id} ->
        {:reply, server_id, snak_servers}
      :error ->
        # Create new SnakTrip.Server
        {:ok, server_id} = Snaktrip.Server.start_link(snaktrip_uuid)
        # Add to list
        snak_servers = Map.put(snak_servers, snaktrip_uuid, server_id)
        # Return
        {:reply, server_id, snak_servers}
    end
  end

end
