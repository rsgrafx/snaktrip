defmodule Snaktrip.Supervisor do
  @moduledoc """
    Manages the Snaktrip Server processes.
  """
  use Supervisor

  @doc """
    We expect to act as the entrypoint for starting
      Snaktrip.Server
  """
  def start_snaktrip(child_uuid) do
    Supervisor.start_child(:snaktrip_sup, [child_uuid])
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :snaktrip_sup)
  end

  def init(_) do
    children = [
      worker(Snaktrip.Server, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
