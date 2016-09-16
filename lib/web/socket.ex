defmodule Snaktrip.Web.Socket do
  @moduledoc """
  This is the request handler.
  """
  @behaviour :cowboy_websocket_handler

  def init({:tcp, :http}, _req, _opts) do
    { :upgrade, :protocol, :cowboy_websocket }
  end

  def websocket_init(_transport_name, req, _opts) do
    Snaktrip.Web.RealtimeServer.join(self())
    { :ok, req, :undefined_state }
  end

  def websocket_handle({:text, msg}, req, state) do
    Snaktrip.Web.RealtimeServer.send_messages(:others, self(), msg)
    {:ok, req, state}
  end

  def websocket_handle(_data, req, state) do
    {:ok, req, state }
  end

  def websocket_info({:send_message, _server_pid, msg}, req, state) do
    {:reply, {:text, msg}, req, state }
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state }
  end

  def websocket_terminate(_reason, _req, _state) do
    Snaktrip.Web.RealtimeServer.leave(self())
    :ok
  end
end
