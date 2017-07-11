defmodule Crawler do
  @moduledoc """
  GenServer that fetches and holds magnet links as a list
  """
  use GenServer
  
  @name __MODULE__

  @type t :: %{ site: String.t, magnets: [title_uri_pair], last_update: integer }
  @type title_uri_pair :: {String.t, String.t}

  ### PUBLIC API

  def start_link(sites) when is_list(sites) do
    GenServer.start_link(__MODULE__, sites, name: @name)
  end

  def fetch_magnets(url) do
    GenServer.call(@name, {:fetch_magnets, url})
  end

  def state do
    GenServer.call(@name, {:state})
  end

  def state(url) do
    GenServer.call(@name, {:state, url})
  end

  def magnets do
    GenServer.call(@name, {:magnets})
  end

  ### INTERNAL API

  @spec init([String.t]) :: {:ok, [Crawler.t]}
  def init(sites) do
    state = Enum.map(sites, &actual_magnet_fetching/1)
    {:ok, state}
  end

  def handle_call({:fetch_magnets, url}, _from, state) do
    new_elem = actual_magnet_fetching(url)

    {:reply, new_elem.magnets, [new_elem | state]}
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:state, url}, _from, state) do
    [site | []] = Enum.filter(state, fn(val) ->
      String.contains?(val.site, url) end)

    {:reply, site, state}
  end

  def handle_call({:magnets}, _from, state) do
    magnets = state
      |> Enum.flat_map(& &1[:magnets])
      |> Enum.map(& elem(&1, 1))

    {:reply, magnets, state}
  end

  ### PRIVATE FUNCTIONS

  @spec actual_magnet_fetching(String.t) :: Crawler.t
  defp actual_magnet_fetching(url) do
    {:ok, response} = HTTPoison.get(url)

    response
    |> Map.get(:body)
    |> Floki.find("a[href^=magnet]")
    |> Enum.take(10)
    |> Enum.map(&pluck_magnet/1)
    |> title_magnet_tuple
    |> add_magnet_list(url)
  end

  defp pluck_magnet({"a", [ {"href", magnet}, _ ], _}), do: magnet

  @spec title_magnet_tuple([String.t]) :: [title_uri_pair]
  defp title_magnet_tuple(uris) do
    Magnet.get(uris, :dn)
    |> (&List.zip [&1, uris]).()
  end

  defp add_magnet_list(magnets, url), do: %{ magnets: magnets, site: url, last_update: :os.system_time() }
end