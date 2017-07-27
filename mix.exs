defmodule PeerMonitor.Mixfile do
  use Mix.Project

  def project do
    [app: :peer_monitor,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [
      mod: {PeerMonitor, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:mldht, git: "https://github.com/Potrimpo/Multinode-MlDHT.git"},
      {:magnet, git: "https://github.com/Potrimpo/magnet.git"},
      {:gen_stage, "~> 0.11"},
      {:csv, "~> 2.0.0"},
      {:httpoison, "~> 0.12"},
      {:floki, "~> 0.17.0"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end
end
