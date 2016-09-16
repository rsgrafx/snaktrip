defmodule Snaktrip.Web.Api do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/snaktrip/:uuid" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, %{data: [
        %{id: 1, locations: %{}}, %{id: 2, locations: %{}}
      ]} |> Poison.encode!)
  end

end
