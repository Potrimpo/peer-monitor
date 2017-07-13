defmodule Dht.Writer do
  def encode_and_print(hash, nodes) do
    Stream.map(nodes, & parse_node_stream(&1, hash))
    |> CSV.encode
    |> Stream.into(File.stream!("data/output.csv", [:append, :utf8]))
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