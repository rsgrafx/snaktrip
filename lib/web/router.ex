defmodule Snaktrip.Web.Router do

  import Plug.Conn

  use Plug.Router
  use Plug.Builder
  use Plug.ErrorHandler

  alias Snaktrip.Video.Download

  plug :fetch_query_params


  plug Plug.Static, at: "/", from: :snaktrip

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

  get "/snaktrip/video/:filename" do
    # Example VIDEO URL.
    data = %{path: "https://s3.amazonaws.com/test-myhotspot/videos/SampleVideo_1280x720_1mb.mp4"}
    tmp_path = "priv/tmp/#{SecureRandom.uuid}.mp4"
    
    {:ok, stats} =
      Download.fetch(data)
      |> Download.write_file(tmp_path)

    filesize = stats.size
    [range_start, range_end] = Download.calculate_range(conn, filesize)
    content_length = range_end - range_start + 2
    conn
      |> put_resp_content_type("audio/mp4")
      |> put_resp_header("content-length", Integer.to_string(content_length))
      |> put_resp_header("accept-ranges", "bytes")
      |> put_resp_header("content-disposition", ~s(inline; filename="#{filename}"))
      |> put_resp_header("content-range", "bytes #{range_start}-#{range_end}/#{filesize}")
      |> send_file(206, tmp_path, range_start, content_length)
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
