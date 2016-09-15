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
    %RethinkDB.Record{data: list} = connection.run(table_list)
    case table_string in list do
      false -> table_create(table_string) |> connection.run
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
