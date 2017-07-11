defmodule PeerMonitor do
  @moduledoc """
  Monitor peers on the DHT for the top 10 torrents  
  """

  use Application

  def start(_type, _args), do: PeerMonitor.Supervisor.start_link

end
