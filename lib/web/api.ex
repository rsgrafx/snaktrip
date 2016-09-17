defmodule Snaktrip.Web.Api do

  use Plug.Router

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

      %{"email" => email } = resp

    resp =
      Snaktrip.User.Manager.fetch(email)
      |> Snaktrip.User.Server.get
      |> Map.from_struct

    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, resp |> Poison.encode!)
  end

  def json({:ok, body, conn}) do
    Poison.decode! body
  end

end
