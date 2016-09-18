defmodule Snaktrip.Web.Api do

  use Plug.Router

  alias Snaktrip.User.Location.Manager, as: LocationManager
  alias Snaktrip.User.Manager, as: UserManager

  plug :match
  plug :dispatch
  plug :fetch_query_params

  plug Plug.Parsers, parsers: [:urlencoded, :json],
                   pass:  ["text/*"],
                   json_decoder: Poison


  get "/snaktrips" do
    %{data: data} = Snaktrip.all
    resp = %{data: data}
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, resp |> Poison.encode!)
  end

  post "/user/account" do
    resp =
      conn
      |> read_body
      |> json
      |> case do
        %{"email" => email } ->
          UserManager.fetch(email: email)
          |> Snaktrip.User.Server.get
          |> Map.from_struct

        _ -> %{"error" => "This endpoint requires your email address."}
      end

    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, resp |> Poison.encode!)
  end

  post "/user/nearby" do
    resp =

    conn
      |> read_body
      |> json

    %{"api_token" => token, "current_location"=> current_location} = resp

      data = LocationManager.fetch(token: token, location: current_location)
        |> Snaktrip.User.Location.Server.locations([])

    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, data |> Poison.encode!)
  end

  def json({:ok, body, conn}) do
    Poison.decode! body
  end

end
