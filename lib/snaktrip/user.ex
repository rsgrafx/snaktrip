defmodule Snaktrip.User do

  defstruct id: nil, email: nil, snaktrips: [], current_location: nil

  use Snaktrip.RethinkDB.Repo
end
