defmodule Dht.Indexer do
  use GenServer

  @name __MODULE__

  ## PUBLIC API

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  ### CALLBACKS

  def init([]) do
    :timer.sleep(1000) # Give MLDHT time to setup before calling it
    :ok = begin_dht_crawl()
    Process.send_after(self(), :write, 2000) # set up timer for writing nodes out to CSV
    {:ok, %{}}
  end

  def handle_cast({:post_node, {hash, node}}, state) do
    # IO.puts "new node! --> #{inspect node}"
    new_state = Map.update(state, hash, [node], fn xs -> [node | xs] end)
    {:noreply, new_state}
  end

  def handle_info(:write, state) do
    :ok = Stream.map(state, fn {hash, nodes} -> Dht.Writer.encode_and_print(hash, nodes) end)
    |> Stream.run

    Process.send_after(self(), :write, 2000)

    {:noreply, %{}} # reset state to avoid duplicate data being written to file
  end

  # PRIVATE FUNCTIONS

  defp begin_dht_crawl() do
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

  defp search_callback(hash, node), do: GenServer.cast(@name, {:post_node, {hash, node}})

end

# "b99f93d2df9472910941c4a315718fb0d1eff191" \
# |> String.upcase \
# |> Base.decode16! \
# |> MlDHT.search(fn node -> \
#     GenServer.cast(Indexer, {:post_node, node}) \
#   end)
