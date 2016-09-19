defmodule Snaktrip.Server do

  use Snaktrip.RethinkDB.Helpers

  use GenServer

  # Starts a process with an existing - Snaktrip.id
  # This would pull the existing data from the Rethink
  def start_link(snak_id) when is_binary(snak_id) do
    GenServer.start(__MODULE__, snak_id, name: via_tuple(snak_id))
  end

  # Starts a *NEW* process - embedding the owner_id
  # into the struct which is kept in the Genserver state
  def start_link(owner_id: user_id) do
    GenServer.start(__MODULE__, owner_id: user_id)
  end

  # Starts a means of searching -> Which could lead to problems.
  # I dont think this should be handled here.
  def start_link(data) when is_map(data) do
    GenServer.start(__MODULE__, data)
  end

  defp via_tuple(snak_id) when is_binary(snak_id) do
    {:via, :gproc, {:n, :l, {:snak_servers, snak_id }}}
  end
  # Fetch the PID - you have the key.
  # Pid already registered in start_link
  def init(snak_id) when is_binary(snak_id) do
    send(self, :fetch_record)
    {:ok, snak_id}
  end
  # Typically when owner is creating new snaktrip
  def init(owner_id: user_id) when is_binary(user_id) do
    key = SecureRandom.uuid
    :gproc.reg {:n, :l, {:snak_servers, key}}
    {:ok, struct(Snaktrip, id: key, owner_id: user_id) }
  end

  #  Up for Review - possibly removal.
  def init(%{owner_id: _, id: _}=opts) when is_map(opts) do
    send(self, :fetch_record)
    {:ok, opts}
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
  def get(pid) when is_pid(pid) do
    current_state(pid)
  end

  def get(snaktrip_id) when is_binary(snaktrip_id) do
    GenServer.call( via_tuple(snaktrip_id), :current_state)
  end

  def current_state(pid) when is_pid(pid) do
    GenServer.call(pid, :current_state)
  end

  @doc """
    Example.
      Snaktrip.Server.new_location(pid, %Snaktrip.Location.t )
  """
  def new_location(pid, location) when is_pid(pid) do
    GenServer.cast(pid, {:add_location, location})
  end

  def new_location(snak_id, location) when is_binary(snak_id) do
    GenServer.cast(via_tuple(snak_id) , {:add_location, location})
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
    snaktrip = fetch_by(opts) || struct(Snaktrip, id: opts[:id], owner_id: opts[:owner_id])
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
      struct(Snaktrip, id: state.id, locations: do_new_location(state, location) )
    Snaktrip.save( Map.from_struct(new_state) )
    {:noreply, new_state}
  end

  defp do_new_location(state, new_location) do
    Map.put(state.locations, new_location.id, Map.from_struct(new_location) )
  end

end
