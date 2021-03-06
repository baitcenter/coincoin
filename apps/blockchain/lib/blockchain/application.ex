defmodule Blockchain.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:blockchain, :port)

    # Define workers and child supervisors to be supervised
    children = [
      {Blockchain.Chain, []},
      {Blockchain.Mempool, []},

      # P2P processes
      {Blockchain.P2P.Peers, []},
      {Task.Supervisor, name: Blockchain.P2P.Server.TasksSupervisor},
      {Task, fn -> Blockchain.P2P.Server.accept(port) end}
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blockchain.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
