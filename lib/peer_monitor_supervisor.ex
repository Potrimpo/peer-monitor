defmodule PeerMonitor.Supervisor do
  use Supervisor

  @name __MODULE__

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: @name)
  end

  def init([]) do
    sites = ["https://thepiratebay.org/top/all"]

    children = [
      # Define workers and child supervisors to be supervised
      worker(Crawler, [sites]),
      worker(Dht.Indexer, [])
    ]

    # supervise/2 is imported from Supervisor.Spec
    supervise(children, strategy: :one_for_one, name: @name)
  end
end