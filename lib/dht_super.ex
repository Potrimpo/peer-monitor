defmodule DHT_super do
  use Supervisor

  @name __MODULE__

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: @name)
  end

  def init([]) do
    children = [
      supervisor(MLDHT, [], [restart: :permanent, id: 1, function: :start])
    ]

    # supervise/2 is imported from Supervisor.Spec
    supervise(children, strategy: :simple_one_for_one)
  end

  def new_node(id), do: Supervisor.start_child(__MODULE__, [id])
end