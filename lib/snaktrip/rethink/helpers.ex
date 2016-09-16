defmodule Snaktrip.RethinkDB.Helpers do

  defmacro __using__(_) do
    quote do
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
