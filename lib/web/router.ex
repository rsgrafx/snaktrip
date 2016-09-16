defmodule Snaktrip.Web.Router do

  import Plug.Conn

  use Plug.Router
  use Plug.Builder
  use Plug.ErrorHandler

  plug :fetch_query_params


  plug Plug.Static, at: "/", from: :snaktrip_app

  if Mix.env == :dev do
    use Plug.Debugger
  end

  plug :match
  plug :dispatch

  get "/favicon.ico" do
    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(200, "nada")
  end


  get "/js/:file" do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_file(200, "priv/app/static/js/#{file}")
  end

  get "/css/:file" do
    conn
    |> put_resp_header("content-type", "text/css")
    |> send_file(200, "priv/app/static/css/#{file}")
  end

  get "/fonts/:file" do
    conn
    |> put_resp_header("content-type", "application/x-font-woff")
    |> send_file(200, "priv/app/static/fonts/#{file}")
  end

  get "/" do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_file(200, "priv/app/index.html")
  end

  forward "/api", to: Snaktrip.Web.Api

  def run do
    { :ok, _ } = Plug.Adapters.Cowboy.http __MODULE__, []
  end

  def not_found(conn, _) do
    send_resp(conn, 404, "not found")
  end

  @spec redirect(Plug.Conn.t, binary, Keyword.t) :: Plug.Conn.t
  def redirect(conn, location, opts \\ [])

  def redirect(%Plug.Conn{state: :sent} = conn, _, _) do
    conn
  end

  def redirect(conn, location, opts) do
    opts = [status: 302] |> Keyword.merge(opts)

    conn
    |> put_resp_header("Location", location)
    |> send_resp(opts[:status], "")
  end


end
