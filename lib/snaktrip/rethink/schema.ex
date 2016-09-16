defmodule Snaktrip.RethinkDB.Schema do

  import RethinkDB.Query, only: [table_list: 0, table_create: 1]

  defmacro __using__(_) do
    quote do
      import RethinkDB.Query
      import Snaktrip.RethinkDB.Schema, only: [
        register_schema: 1,
        connection: 0,
        table_name: 1]
    end
  end

  @doc """
    Ensure Table is exists or Create one.
  """
  def connection do
    Snaktrip.Connection
  end

  def register_schema(mod) when is_atom(mod) do
    table_name(mod)
      |> do_register_schema
  end

  def register_schema(mod) when is_binary(mod) do
    do_register_schema(mod)
  end

  defp do_register_schema(table_string) when is_binary(table_string) do

    table_list =
      case Process.whereis(:rethinkdb_manager) do
        nil ->
          Snaktrip.RethinkDB.Manager.start_link(connection)
          %{data: list} = connection.run(table_list)
          list
        process when is_pid(process) ->
          GenServer.call(:rethinkdb_manager, :tables)
      end

    case table_string in table_list do
      false ->
        Snaktrip.RethinkDB.Manager.add_table(table_string)
        table_create(table_string) |> connection.run
      _ -> {:ok, :table_exists}
    end

  end

  def table_name(module) do
    module
     |> to_string
     |> String.split(".")
     |> List.last
     |> Mix.Utils.underscore
     |> Inflex.pluralize
  end

end
