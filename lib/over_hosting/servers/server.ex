defmodule OverHosting.Servers.Server do
  use GenServer


  # TODO:  Create a model to hold Docker server information and pull from it instead of only localhost with hardcoded key paths...
  @docker_server %{
    baseUrl: "localhost:3128",
    ssl_options: [
      {:certfile, '../docker.crt'},
      {:keyfile,  '../docker.key'},
    ]
  }


  import Ecto.Query
  alias OverHosting.Repo
  alias OverHosting.Models


  defstruct model: nil, id: "", docker: nil


  #@docker_cmd "docker run -t -i --rm java"


  ## Interface - serverless


  def start_link(id) do
    #query = from s in Models.Server,
    #  where: s.name == ^name and s.group == ^group,
    #  select: s
    #start_link(Repo.one!(query))
    #GenServer.start_link(__MODULE__, Repo.get!(Models.Server, id))
    GenServer.start_link(__MODULE__, id)
  end

  #def start_link(model) do
  #  GenServer.start_link(__MODULE__, model)
  #end


  def get_server(id) do
    :gproc.where(get_gproc_name(id))
  end


  ## Interface - server


  def get_server_state(server) when is_pid(server) do
    GenServer.call(server, :get_server_state)
  end


  def server_unload(server, stopServer) when is_pid(server) and is_atom(stopServer) do
    GenServer.cast(server, {:server_unload, stopServer})
  end


  def server_start(server) when is_pid(server) do
    GenServer.cast(server, :server_start)
  end


  def server_stop(server) when is_pid(server) do
    GenServer.cast(server, :server_stop)
  end


  ## Callbacks


  def init(id) do
    s = self()
    case :gproc.reg_or_locate(get_gproc_name(id)) do
      {^s, _} ->
        model = Repo.get!(Models.Server, id)
        {:ok, docker} = Docker.start_link(@docker_server)
        state = %OverHosting.Servers.Server{model: model, id: id}
        OverHosting.Endpoint.broadcast("servers:"<>state.id, "server:load", %{})
        {:ok, state}
      _ -> {:stop, "duplicate name"}
    end
  end


  def terminate(_reason, state) do
  end


  def handle_call(:get_server_state, _from, state) do
    ret = %{loaded: :yes}
    {:reply, ret, state}
  end

  def handle_call(msg, from, state) do
    IO.inspect "Got unknown call of #{inspect msg} from #{inspect from} in process #{inspect self()} with state of:\n#{inspect state}"
    {:reply, :unhandled, state}
  end


  def handle_cast({:server_unload, stopServer}, state) do
    IO.inspect "Unloading server #{inspect self()}"
    OverHosting.Endpoint.broadcast("servers:"<>state.id, "server:unload", %{})
    {:stop, :normal, state}
  end

  def handle_cast(msg, state) do
    IO.inspect "Got unknown cast of #{inspect msg} in process #{inspect self()} with state of:\n#{inspect state}"
    {:noreply, state}
  end


  def handle_info(msg, state) do
    IO.inspect "Got unknown message of #{inspect msg} in process #{inspect self()} with state of:\n#{inspect state}"
    {:noreply, state}
  end


  #def handle_call(:is_started, _from, state) do
    #{:reply, false, state}
  #end
  #def handle_call(:start, _from, state) do
    #case state.p do
      #nil ->
        #OverHosting.Endpoint.broadcast("servers:"<>state.name, "server:start", %{})
        #p = Porcelain.spawn("docker", ["run", "--rm", "java", "/data/launch.sh"], [in: :receive, out: {:send, self()}])
        #{:reply, :ok, Map.put(state, :p, p)}
      #_ -> {:reply, {:error, "Server already running"}, state}
    #end
  #end
  #def handle_call(:stop, _from, state) do
  #  case state.p do
  #    nil -> {:reply, {:error, "Server not running"}, state}
  #     p ->
  #      Proc.send_input(p, "\nstop\n")
  #      {:reply, :ok, state}
  #  end
  #end
  #def handle_call(:kill, _from, state) do
  #  case state.p do
  #    nil -> {:reply, {:error, "Server not running"}, state}
  #    p ->
  #      Proc.stop(p)
  #      {:reply, :ok, state}
  #  end
  #end
  #def handle_call({:cmd, cmd}, _from, state) do
  #  case state.p do
  #    nil -> {:reply, {:error, "Server not running"}, state}
  #    p ->
  #      Proc.send_input(p, cmd <> "\n")
  #      {:reply, :ok, state}
  #  end
  #end
  #def handle_call(:is_running, _from, state) do
  #  case state.p do
  #    nil -> {:reply, false, state}
  #    p -> case Proc.alive?(p) do
  #      true -> {:reply, true, state}
  #      false -> {:reply, false, Map.put(state, :p, nil)}
  #    end
  #  end
  #end
  #
  #def handle_cast({:cmdnbone, _cmd}, state) do
  #  {:noreply, state}
  #end
  #
  #def handle_info({_pid, :data, :out, log}, state) do
  #  OverHosting.Endpoint.broadcast("servers:"<>state.name, "server:log", %{log: log})
  #  {:noreply, state}
  #end
  #def handle_info({_pid, :result, result}, state) do
  #  OverHosting.Endpoint.broadcast("servers:"<>state.name, "server:stop", %{result: result.status})
  #  Proc.stop(state.p)
  #  {:noreply, Map.put(state, :p, nil)}
  #end

  
  defp get_gproc_name(id) when is_binary(id) do
    {:n, :l, "servers:"<>id}
  end
  defp get_gproc_name(id) do
    get_gproc_name(to_string(id))
  end
  

  #defp strip_invalid_from_name(name) do
  #  String.replace(name, ~r/[^-\.a-zA-Z0-9\/]/, "")
  #end

  #defp get_complete_name(group, name) do
  #  strip_invalid_from_name(group <> "/" <> name)
  #end

  defp get_base_path() do
    base_path = Path.expand(Application.get_env(:over_hosting, OverHosting.Servers)[:data_folder])
    File.mkdir_p!(base_path) # Make sure the path exists, or die
    base_path
  end

  defp get_path(section) do
    path = Path.expand(Path.join(get_base_path(), section))
    File.mkdir_p!(path) # Make sure the path exists, or die
    path
  end
end
