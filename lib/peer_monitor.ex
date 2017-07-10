defmodule PeerMonitor do
  @moduledoc """
  Monitor peers on the DHT for the top 10 torrents  
  """

  @name __MODULE__
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    sites = ["https://thepiratebay.org/top/all"]

    children = [
      # Define workers and child supervisors to be supervised
      # supervisor(DHT_super, []),
      worker(Crawler, [sites])
    ]

    opts = [strategy: :one_for_one, name: @name]
    Supervisor.start_link(children, opts)
  end

  def index() do
  end

end
