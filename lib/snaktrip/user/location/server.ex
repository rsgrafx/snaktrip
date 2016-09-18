defmodule Snaktrip.User.Location.Server do

  use GenServer

  def start_link(%{token: token, location: location}) do
    GenServer.start_link(__MODULE__, %{token: token, location: location})
  end

  def init(state) do
    send self(), :build_locations
    {:ok, state}
  end

  def locations(pid, current_location) do
    GenServer.call(pid, {:locations, current_location})
  end

  def handle_call({:locations, current_location}, _, state) do
    if current_location != state.location do
      # This is where that location list would be update.
      # but in the interest of time
      {:reply, state, state}
    else
      {:reply, state, state}
    end
  end

  def handle_info(:build_locations, %{token: token, location: location}) do
    # Snaktrip.all.data # hack. for the proof of concept.
    data = %{token: token, location: "#Location< long, lat>", nearby: Snaktrip.all.data }

    {:noreply, data}
  end

end
