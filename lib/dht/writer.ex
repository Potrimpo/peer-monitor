defmodule Dht.Writer do
  @output_dir Application.get_env(:peer_monitor, :output_dir)

  def encode_and_print(hash, nodes) do
    output_file = @output_dir <> "/" <> to_string(:os.system_time) <> ".csv" 

    Stream.map(nodes, & parse_node_stream(&1, hash))
    |> CSV.encode
    |> Stream.into(File.stream!(output_file, [:append, :utf8]))
    |> Stream.run
  end

  defp parse_node_stream({ip, port}, hash) do
    ip = ip
    |> Tuple.to_list
    |> Enum.join(".")

    port = Integer.to_string(port)

    hash = Base.encode16(hash)

    csv_encode_format({ip, port}, hash)
  end

  defp csv_encode_format({ip, port}, hash), do: [ hash, ip, port ]
end