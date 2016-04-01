defmodule OverHosting.ServerChannel do
  use OverHosting.Web, :channel


  #import Ecto.Query
  alias OverHosting.Repo
  alias OverHosting.Models


  def join("servers:" <> server_id, payload, socket) do
    server_model = Repo.get!(Models.Server, server_id)
    if authorized?(server_model, payload) do
      {:ok, server_id, assign(socket, :server_id, server_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # Client requested state of server, send what is requested
  def handle_in("state", _payload, socket) do
    #push socket, "state", get_server_state(socket.assigns.server_id)
    IO.inspect "Sent a state request"
    {:reply, {:ok, get_server_state(socket.assigns.server_id)}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (servers:lobby).
  def handle_in("server:cmd", payload, socket) do
    #case OverHosting.Servers.Server.
    OverHosting.Servers.send_cmd(socket.assigns.server_id, payload["cmd"])
    {:noreply, socket}
  end

  def handle_in("server:load", _payload, socket) do
    IO.inspect "load #{socket.assigns.server_id}"
    case OverHosting.Servers.Server.get_server(socket.assigns.server_id) do
      :undefined ->
        OverHosting.Servers.load_server(socket.assigns.server_id)
      _ ->
        push socket, "msg", %{msg: "Attempted to load a server that is already loaded"}
    end
    {:noreply, socket}
  end
  def handle_in("server:unload", _payload, socket) do
    case OverHosting.Servers.Server.get_server(socket.assigns.server_id) do
      :undefined ->
        push socket, "msg", %{msg: "Attempted to unload server when it is already unloaded"}
      server ->
        OverHosting.Servers.Server.server_unload(server, false)
    end
    {:noreply, socket}
  end
  def handle_in("server:start", _payload, socket) do
    case OverHosting.Servers.Server.get_server(socket.assigns.server_id) do
      :undefined ->
        push socket, "msg", %{msg: "Attempted to start a server that is not yet loaded"}
      server ->
        OverHosting.Servers.Server.server_start(server)
    end
    {:noreply, socket}
  end
  def handle_in("server:stop", _payload, socket) do
    case OverHosting.Servers.Server.get_server(socket.assigns.server_id) do
      :undefined ->
        push socket, "msg", %{msg: "Attempted to stop a server that is not yet loaded"}
      server ->
        OverHosting.Servers.Server.server_stop(server)
    end
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end


  defp get_server_state(id) do
    case OverHosting.Servers.Server.get_server(id) do
      :undefined ->
        %{loaded: :no}
      server ->
        OverHosting.Servers.Server.get_server_state(server)
    end
  end


  defp authorized?(_server_model, _payload) do
    true
  end
end
