defmodule SnaktripApp do

  use Application

  def start _, _ do
    import Supervisor.Spec, warn: false

    children = [
      worker(Snaktrip.Database, []),
      worker(Snaktrip.Manager, [])
    ]
    opts = [strategy: :one_for_one, name: SnaktripApp.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
