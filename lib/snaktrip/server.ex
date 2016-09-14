defmodule Snaktrip.Server do
  use GenServer

  def start_link(uuid_key) do
    GenServer.start(__MODULE__, uuid_key)
  end

  def init(key) do
    snaktrip = fetch_or_create(key) || struct(Snaktrip, id: key)
    # Find or Create * Trip with Key
    {:ok, snaktrip}
  end

  defp fetch_or_create(key) do
    # - fetch the state from a Repo.
  end

  @doc """
    %{id: id} = Snaktrip.Location{id: int}

    Get current state of the trip.

    %SnakTrip{ id: "string",
      locations: %{
        id => Snaktrip.Location.t,
        id => Snaktrip.Location.t
      }}
  """

  def get(pid) do
    current_state(pid)
  end

  def current_state(pid) do
    GenServer.call(pid, :current_state)
  end

  @doc """
    Example.
      Snaptrip.Server.new_location(pid, %Snaktrip.Location.t )
  """
  def new_location(pid, location) do
    GenServer.cast(pid, {:add_location, location})
  end

  # Callbacks
  def handle_call(:current_state, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:add_location, location}, state) do
    locations = Map.put(state.locations, location.id, location)
    state = struct(Snaktrip, id: state.id, locations: locations)
    {:noreply, state}
  end
end
