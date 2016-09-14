defmodule Snaktrip.Database do
  use RethinkDB.Connection

  @moduledoc """
    Queries can be run without providing a connection (it will use the name connection).
    import RethinkDB.Query
      table("locations") |> SnakTrip.Database.run
  """
end
