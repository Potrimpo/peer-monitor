defmodule Indexer do
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
    {:ok, []}
  end

  def handle_cast({:post_node, node}, state) do
    IO.puts "new node! --> #{inspect node}"

    {:noreply, [node | state]}
  end

  # PRIVATE FUNCTIONS

  defp begin_dht_crawl() do
    _oks = Crawler.magnets
      |> Magnet.get(:xt) # take the content hash
      |> Enum.take(1) # just testing
      |> Enum.map(&searcher/1)

    IO.puts "DHT crawl has begun"
    :ok
  end

  defp searcher("urn:btih:" <> hash) do
    hash
    |> String.upcase
    |> Base.decode16!
    |> MLDHT.search(&search_callback/1)
  end

  defp search_callback(node), do: GenServer.cast(@name, {:post_node, node})

end

# "b99f93d2df9472910941c4a315718fb0d1eff191" \
# |> String.upcase \
# |> Base.decode16! \
# |> MLDHT.search(fn node -> IO.puts "new node! --> #{inspect node}" end)