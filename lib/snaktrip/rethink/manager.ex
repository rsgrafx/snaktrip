defmodule Snaktrip.RethinkDB.Manager do
  use GenServer
  @doc """
    Simple genserver to keep list of
    All tables in Rethink system so as to
    not have to query all the time *
      *
  """
  def start_link(rethink_connection) do
    GenServer.start_link(__MODULE__, rethink_connection, name: :rethinkdb_manager)
  end

  def all_tables do
    GenServer.call(:rethinkdb_manager, :tables)
  end

  def add_table(table_name) do
    GenServer.cast(:rethinkdb_manager, {:add_table, table_name} )
  end

  # Callbacks do

  def init(conn) do
    send(self(), :fetch_tables)
    {:ok, conn}
  end

  def handle_cast({:add_table, table_name}, state) do
    {:noreply, [table_name|state]}
  end

  def handle_call(:tables, _, state) do
    {:reply, state, state}
  end

  def handle_info(:fetch_tables, conn) do
    %{data: list} = RethinkDB.Query.table_list |> conn.run
    {:noreply, list}
  end

end
