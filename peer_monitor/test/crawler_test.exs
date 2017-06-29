defmodule CrawlerTest do
  use ExUnit.Case
  doctest Crawler

  @url "https://thepiratebay.org/top/all"

  test "check Crawler.find_magnets/1 is returning list of magnet links" do
    magnets = Crawler.fetch_magnets(@url)

    assert is_list(magnets)
    assert length(magnets) === 10
    assert Regex.match?(~r/^magnet:\?/, Enum.at(magnets, 0))
  end
end
