defmodule Snaktrip do
  @moduledoc """

  A SnakTrip represents the * MINI-Guide
    Created by our users.

    Snaktrip{id: "uuid",
      locations: %{ int => %Snaktrip.Location{ address: "string", name: "string", latlong: [lat, long] } }
    }
  """
  defstruct id: nil, owner_id: nil, locations: %{}

  use Snaktrip.RethinkDB.Repo

end
