defmodule SnaktripApp do
  use Application

  def start_cowboy do

    dispatch = :cowboy_router.compile([ {:_, routes} ] )

    {:ok, _} = :cowboy.start_http(:snaktrip_app, 100, [{:port, 8090}],

    [{:env, [{:dispatch, dispatch}]}])
  end


  def start _, _ do

    start_cowboy

    import Supervisor.Spec, warn: false

    children = [
      worker(Snaktrip.Connection, [[db: "snaktrip_app"]]),
      worker(Snaktrip.Manager, []),
      worker(Snaktrip.Web.Router, [], function: :run)

    ]
    opts = [strategy: :one_for_one, name: SnaktripApp.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def routes do
    [
      {"/socket", Snaktrip.Web.Socket, []},
      {:_, Plug.Adapters.Cowboy.Handler, {Snaktrip.Web.Router, []}}
    ]
  end

end
