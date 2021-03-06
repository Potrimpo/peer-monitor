defmodule PeerMonitor do
  use Application

  import Supervisor.Spec

  @name __MODULE__

  def start(_type, _args) do
    Supervisor.start_link(__MODULE__, [], name: @name)
  end

  def init([]) do
    sites = ["https://thepiratebay.org/top/all"]

    children = [
      worker(Crawler, [sites]),
      supervisor(Dht, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end