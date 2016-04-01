defmodule OverHosting.Servers do
  use Supervisor

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
    Supervisor.start_link(__MODULE__, [], name: OverHosting.Servers.Supervisor)
  end

  def init([]) do
    children = [
      worker(OverHosting.Servers.Server, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  #def get_children() do
  #  Agent.get(__MODULE__, fn children ->
  #    children
  #  end)
  #end

  #def get_child(name) when is_binary(name) do
  #  Agent.get(__MODULE__, fn children ->
  #    children[name]
  #  end)
  #end

  def get_server(id) do
    OverHosting.Servers.Server.get_server(id)
  end

  def load_server(id) do
    Supervisor.start_child(OverHosting.Servers.Supervisor, [id])
  end

  #def server_running?(name) do
  #  case get_server(name) do
  #    nil -> {:error, "Server is not loaded"}
  #    pid -> GenServer.call(pid, :is_running)
  #  end
  #end

  #def start_server(name) do
  #  case get_server(name) do
  #    nil -> {:error, "Server is not loaded"}
  #    pid -> GenServer.call(pid, :start)
  #  end
  #end

  #def stop_server(name) do
  #  case get_server(name) do
  #    nil -> {:error, "Server is not loaded"}
  #    pid -> GenServer.call(pid, :stop)
  #  end
  #end

  #def kill_server(name) do
  #  case get_server(name) do
  #    nil -> {:error, "Server is not loaded"}
  #    pid -> GenServer.call(pid, :kill)
  #  end
  #end

  #def send_cmd(name, cmd) do
  #  case get_server(name) do
  #    nil -> {:error, "Server is not loaded"}
  #    pid -> GenServer.call(pid, {:cmd, cmd})
  #  end
  #end
end
