defmodule Dht.PeerStore do
  @moduledoc"""
  GenStage that receives new nodes from MlDHT and passes them down to the Writer

  state is stored in a map of %{ infohash: [node] }
  """

  @name __MODULE__
  @search_interval 1000 * 60 * 60 # one hour

  use GenStage

  ## PUBLIC API

  def start_link do
    GenStage.start_link(__MODULE__, [], name: @name)
  end

  ### CALLBACKS

  def init([]) do
    :timer.sleep(1000) # Give MLDHT time to setup before calling it

    Process.send_after(self(), :search, @search_interval) # reset timer for DHT scraping
    :ok = Dht.Scraper.new_search()

    {:producer, {0, []}}
  end

  # Periodically called to initiate DHT scrapes
  def handle_info(:search, state) do
    Process.send_after(self(), :search, @search_interval) # reset timer for DHT scraping

    :ok = Dht.Scraper.new_search()

    {:noreply, [], state}
  end

  # If we receive peers and we have buffered demand to fulfil, emit relevant # of events
  def handle_cast({:post_node, peer_tuple}, {buff, peers}) when buff > 0 do
    [peer_tuple | peers]
    |> emit_events(buff)
  end

  def handle_cast({:post_node, peer_tuple}, {buff, peers}) do
    # IO.puts "new node! --> #{inspect node}"
    new_state = { buff, [peer_tuple | peers] }
    {:noreply, [], new_state}
  end

  # If we have nothing to give, buffer the demand
  def handle_demand(demand, {buff, []}) do
    new_state = {buff + demand, []}
    {:noreply, [], new_state}
  end

  def handle_demand(demand, {buff, peers}) do
    emit_events(peers, buff + demand)
  end

  defp emit_events(peers, demand) when length(peers) >= demand do
    events = Enum.take(peers, demand)
    new_peer_count = Enum.drop(peers, demand)

    {:noreply, events, {0, new_peer_count}}
  end

  defp emit_events(peers, demand) do
    remainder = demand - length(peers)

    {:noreply, peers, {remainder, []}}
  end

end
