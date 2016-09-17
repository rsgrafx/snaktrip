defmodule Snaktrip.RethinkDB.Helpers do

  @callback record(RethinkDB.Record.t, String.t) :: any

  @callback collection(RethinkDB.Collection.t) :: any

  defmacro __using__(_) do
    quote do

      @behaviour Snaktrip.RethinkDB.Helpers

      def from_rethink(rethink_obj, obj_id) do
        case rethink_obj do
          %RethinkDB.Record{}     -> __MODULE__.record(rethink_obj, obj_id)
          %RethinkDB.Collection{} -> __MODULE__.collection(rethink_obj)
        end
      end
      # import Snaktrip.RethinkDB.Helpers
    end
  end

end
