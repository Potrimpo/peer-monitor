defmodule Dht.Writer do

  use GenStage

  @name __MODULE__
  @output_dir Application.get_env(:peer_monitor, :output_dir)
  @file_switch_interval 1000 * 60 * 60 # one hour

  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    Process.send_after(self(), :file_switch, @file_switch_interval) # write data to a new file from now on
    file = file_from_time()

    {:consumer, file, subscribe_to: [Dht.PeerStore]}
  end

  def handle_info(:file_switch, _file) do
    new_file = file_from_time()

    {:noreply, [], new_file}
  end

  def handle_events(events, _from, file) do
    :ok = encode_and_write(events, file)

    IO.puts "Dht.Writer successfully encoded & written! \n events == #{inspect events}"

    {:noreply, [], file}
  end

  def encode_and_write(peer_tuples, file) do
    Stream.map(peer_tuples, &parse_peer_stream/1)
    |> CSV.encode
    |> Stream.into(File.stream!(file, [:append, :utf8]))
    |> Stream.run
  end

  # PRIVATE FUNCTIONS

  defp parse_peer_stream({ hash, {ip, port} }) do
    ip = ip
    |> Tuple.to_list
    |> Enum.join(".")

    port = Integer.to_string(port)

    hash = Base.encode16(hash)

    csv_encode_format({ip, port}, hash)
  end

  defp csv_encode_format({ip, port}, hash), do: [ hash, ip, port ]

  defp file_from_time, do: @output_dir <> "/" <> to_string(:os.system_time) <> ".csv" 

end

# "b99f93d2df9472910941c4a315718fb0d1eff191" \
# |> String.upcase \
# |> Base.decode16! \
# |> MlDHT.search(fn node -> \
#     GenServer.cast(Indexer, {:post_node, node}) \
#   end)