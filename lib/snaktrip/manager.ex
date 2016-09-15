defmodule Snaktrip.Manager do
  use GenServer
  @moduledoc """
    Represents the Caching system that maps
    -> Snaktrip uuids to GenServer pids that maintain the STATE
    * if no pid exists will generate a new Process
      * pulling last known state from the Repo.
  """

  def start_link do
    # Will eventually modify to pull in last known state
    # From ETS repo.
    GenServer.start_link(__MODULE__, %{}, name: :snak_manager)
  end

  @doc """
    Calls into the Cache
      when your are sure of the <ID> of the snaktrip
      # Snaktrip.Server Process
      returns #PID< Snaktrip. process>
  """
  def fetch(snaktrip_uuid) do
    GenServer.call(:snak_manager, {:server_process, snaktrip_uuid} )
  end

  @doc """
    Calls into the Cache - creates server process which
      maintains the state of individual snaktrip.
      # This is a entry point for app
      # -> pass in the user-id- * API-TOKEN -
      # Snaktrip.Server Process
      returns #PID< Snaktrip. process> ( new record )
  """
  def start_new(owner_id: owner_id) do
    GenServer.call(:snak_manager, {:server_process, owner_id: owner_id})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:server_process, owner_id: owner_id}, snak_servers) do
    do_handle_call(snak_servers, owner_id: owner_id)
  end

  def handle_call({:server_process, snaktrip_uuid}, _, snak_servers) do
    do_handle_call(snak_servers, snaktrip_uuid)
  end

  def do_handle_call(snak_servers, owner_id: owner_id) do
    {:ok, server} = Snaktrip.Server.start_link(owner_id: owner_id)

    %{id: snaktrip_uuid} = Snaktrip.Server.get(server)

    snak_servers = Map.put(snak_servers, snaktrip_uuid, server)
    
    {:reply, server, snak_servers}
  end

  def do_handle_call(snak_servers, snaktrip_uuid) do
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
