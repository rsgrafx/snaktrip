defmodule Snaktrip.Server do

  use Snaktrip.RethinkDB.Helpers

  use GenServer

  def start_link(snak_id) when is_binary(snak_id) do
    GenServer.start(__MODULE__, snak_id)
  end

  def start_link(data) when is_map(data) do
    GenServer.start(__MODULE__, data)
  end

  def start_link(owner_id: user_id) do
    GenServer.start(__MODULE__, owner_id: user_id)
  end

  # The situation is that in order to maintain integrity -
  # I have to place the user_id in there.

  # Pattern match typically for scoping
  # Passing in API KEY \ owner_id
  def init(%{owner_id: _, id: _}=opts) when is_map(opts) do
    send(self, :fetch_record)
    {:ok, opts}
  end

  # Typically when owner is creating new snaktrip
  def init(owner_id: user_id) when is_binary(user_id) do
    # Find or Create * Trip with Key
    {:ok, struct(Snaktrip, id: SecureRandom.uuid, owner_id: user_id)}
  end

  # Fetch the PID - you have the key.
  def init(snak_id) when is_binary(snak_id) do
    send(self, :fetch_record)
    {:ok, snak_id}
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
      Snaktrip.Server.new_location(pid, %Snaktrip.Location.t )
  """
  def new_location(pid, location) do
    GenServer.cast(pid, {:add_location, location})
  end

  # Callbacks # Initialize State
  def handle_info(:fetch_record, snak_id) when is_binary(snak_id) do
    snaktrip =
      Snaktrip.fetch(snak_id)
      |> from_rethink(snak_id)
      |> case do
        %RethinkDB.Record{data: nil, profile: nil} ->
          struct(Snaktrip, id: snak_id)
        {:table, :empty} ->
          struct(Snaktrip, id: snak_id)
        snaktrip -> snaktrip
      end
    {:noreply, snaktrip}
  end

  def handle_info(:fetch_record, opts) when is_map(opts) do
    snaktrip = fetch_by(opts) || struct(Snaktrip, id: opts[:uuid_key], user_id: opts[:user_id])
    {:noreply, snaktrip}
  end

  defp fetch_by(%{owner_id: nil, id: snak_id}),
    do: Snaktrip.fetch(snak_id) |> from_rethink(snak_id)

  defp fetch_by(%{owner_id: user_id, id: snak_id}),
    do: Snaktrip.fetch_by(%{owner_id: user_id, id: snak_id}) |> from_rethink(snak_id)

  def collection(%RethinkDB.Collection{data: []}) do
    {:table, :empty}
  end

  def collection(%RethinkDB.Collection{data: [%{"id" => id, "locations" => locations, "owner_id" => owner}]}) do
    struct(Snaktrip, id: id, owner_id: owner, locations: locations)
  end

  def record(%RethinkDB.Record{data: %{"id" => id, "locations" => locations, "owner_id" => owner}}, _) do
    struct(Snaktrip, id: id, owner_id: owner, locations: locations)
  end

  def record(%RethinkDB.Record{data: nil}, snak_id) do
    struct(Snaktrip, id: snak_id)
  end

  def handle_call(:current_state, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:add_location, location}, state) do
    new_state =
      struct(Snaktrip, id: state.id, locations: new_location(state, location) )
    Snaktrip.save( Map.from_struct(new_state) )
    {:noreply, new_state}
  end

  defp new_location(state, new_location) do
    Map.put(state.locations, location.id, Map.from_struct(new_location) )
  end

end
