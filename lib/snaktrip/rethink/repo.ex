defmodule Snaktrip.RethinkDB.Repo do

  @moduledoc """
  Represents the Query interface that connects
    with RethinkDB
  """
  use Snaktrip.RethinkDB.Schema

  defmacro __using__(_) do
    quote do

      import RethinkDB.Query
      import Snaktrip.RethinkDB.Schema, only: [connection: 0]
      # import Snaktrip.RethinkDB.Repo, only: [all: 0, fetch: 1, fetch_by: 1, save: 1, test: 0]
      # def table_data,  do: Snaktrip.RethinkDB.Schema.register_schema(__MODULE__)

      def table_name do
        register_schema(table_name(__MODULE__)) |> IO.inspect
        table_name(__MODULE__)
      end

      @doc """
        Fetch all records for a given table.
      """

      @spec all() :: RethinkDB.Collection.t
      def all do
        table(table_name)
        |> run
      end

      @doc """
        Fetch id within a table of records.
          returns a RethinkDB.Record
      """
      @spec fetch(String.t) :: RethinkDB.Record.t
      def fetch(id) do
        table(table_name)
        |> get(id)
        |> run
      end

      def fetch_by(opts \\ %{}) do
        table(table_name)
          |> filter(opts)
          |> run
      end

      @doc """
        Insert new record in given * Objects.
      """
      @spec save(Map.t) :: RethinkDB.Record.t
      def save(record)
      when is_map(record) do
        table(table_name)
        |> insert(record)
        |> run
      end

      def run(rethink_query) do
        rethink_query |> connection.run
      end

    end
  end

end
