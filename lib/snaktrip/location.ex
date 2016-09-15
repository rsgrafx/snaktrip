defmodule Snaktrip.Location do
  @moduledoc """
    Represents the Location resource that builds up a Snaptrip
    %Snaktrip.Location{ address: "string", name: "string", latlong: [lat, long] }
  """
  defstruct id: nil, address: nil, name: nil, latlong: nil

  use Snaktrip.RethinkDB.Repo

end
