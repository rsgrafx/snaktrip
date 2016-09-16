defmodule Snaktrip.User do
  
  defstruct id: nil, email: nil, snaktrips: []

  use Snaktrip.RethinkDB.Repo
end
