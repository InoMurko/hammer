defmodule Blitzy.Supervisor do
  use Supervisor

  def start_link(:ok) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      :hackney_pool.child_spec(:rpc_pool,  [timeout: 15000, max_connections: 500]),
      supervisor(Task.Supervisor, [[name: Blitzy.TasksSupervisor]])
    ]

    supervise(children, [strategy: :one_for_one])
  end

end
