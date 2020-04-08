defmodule Tock.Supervisor do
  @moduledoc false

  use DynamicSupervisor

  #
  # client
  #

  @spec start_link :: Supervisor.on_start()
  def start_link do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec start_server(Keyword.t()) :: DynamicSupervisor.on_start_child()
  def start_server(opts) do
    spec = Map.new()
    spec = Map.put(spec, :id, Tock.Server)
    spec = Map.put(spec, :start, { Tock.Server, :start_link, [opts] })

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  #
  # callbacks
  #

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
