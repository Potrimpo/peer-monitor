defmodule DHT_superTest do
  use ExUnit.Case
  doctest DHT_super

  test "ensure DHT nodes can be added dynamically" do
    {:ok, child} = DHT_super.new_node
  end
end
