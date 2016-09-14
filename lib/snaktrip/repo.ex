defmodule Snaktrip.Repo do
  @moduledoc """
  Represents the Query interface that connects
    with RethinkDB
  """
  import RethinkDB.Query

  @connection Snaktrip.Database

  @doc """
    Fetch all records for a given table.
  """
  def all(table_name) when is_binary(table_name) do
    table(table_name)
    |> run
  end

  @doc """
    Fetch id within a table of records.
  """
  def fetch(table_name, id)
  when is_binary(table_name) do
    table(table_name)
    |> get(id)
    |> run
  end

  @doc """
    Insert new record in given * Objects.
  """
  def save(table_name, record)
  when is_map(record) do
    table(table_name)
    |> insert(record)
    |> run
  end


  defp run(rethink_query) do
    rethink_query  |> @connection.run
  end

end
