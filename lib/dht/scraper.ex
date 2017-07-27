defmodule Dht.Scraper do

  def new_search do
    _oks = Crawler.magnets
    |> Magnet.get(:xt) # take the content hash
    |> Enum.map(&parse_and_search/1)

    :ok
  end

  defp parse_and_search("urn:btih:" <> hash) do
    hash
    |> String.upcase
    |> Base.decode16!
    |> dht_search
  end

  defp dht_search(hash) do
    MlDHT.search(hash, fn node -> search_callback(hash, node) end)
  end

  defp search_callback(hash, node) do
    GenServer.cast(Dht.PeerStore, {:post_node, {hash, node}})
  end

end